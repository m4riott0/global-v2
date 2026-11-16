# Claude Code Global V2 - Windows + VS Code
# Uso (PowerShell):  irm https://raw.githubusercontent.com/SEU_USUARIO/claude-installers/main/install-global-v2.ps1 | iex
# Personaliza o Claude Code (~\.claude). NAO instala o Claude Code.

# >>> Edite apenas estas tres linhas depois de criar o repositorio no GitHub <<<
$__CGV2_Owner  = "m4riott0"
$__CGV2_Repo   = "global-v2"
$__CGV2_Branch = "main"

$__CGV2_LocalRoot = if ($PSCommandPath) { Split-Path -Parent $PSCommandPath } else { $null }

function Install-ClaudeGlobalV2 {
    param([string]$Owner, [string]$Repo, [string]$Branch, [string]$LocalRoot)

    $ErrorActionPreference = "Stop"
    $Version  = "2.1"
    $Marker   = "claude-code-global-v2"
    $Utf8     = New-Object System.Text.UTF8Encoding($false)
    $Target   = Join-Path $HOME ".claude"
    $Managed  = @("CLAUDE.md", "settings.json", "rules", "skills", "agents", "hooks")
    $Obsolete = @("rules\architecture.md")   # removido na 2.1 (conteudo movido para CLAUDE.md)

    function Say([string]$m, [string]$c = "Gray") { Write-Host $m -ForegroundColor $c }
    function ReadText([string]$p) { [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) }
    function WriteText([string]$p, [string]$t) { [IO.File]::WriteAllText($p, $t, $Utf8) }
    function HasProp($o, [string]$n) { $null -ne $o -and $null -ne $o.PSObject.Properties[$n] }
    function SetProp($o, [string]$n, $v) {
        if (HasProp $o $n) { $o.$n = $v } else { $o | Add-Member -NotePropertyName $n -NotePropertyValue $v }
    }

    # Windows PowerShell 5.1 serializa arrays como {"value":[...]} sem isto.
    Remove-TypeData -TypeName System.Array -ErrorAction SilentlyContinue

    Say ""
    Say "== Claude Code Global V2 ($Version) ==" Cyan

    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Say "Aviso: comando 'claude' nao encontrado. A configuracao sera instalada mesmo assim;" Yellow
        Say "este pacote e para quem ja tem o Claude Code instalado." Yellow
    }

    # ---- 1. Localizar o pacote (pasta local ou download do GitHub) ----
    $tempDir = $null
    $source = $null
    if ($LocalRoot) {
        foreach ($c in @((Join-Path $LocalRoot "global-v2"), $LocalRoot)) {
            if ((Test-Path (Join-Path $c "CLAUDE.md")) -and (Test-Path (Join-Path $c "skills"))) { $source = $c; break }
        }
    }
    if (-not $source) {
        if ($Owner -eq "SEU_USUARIO") {
            throw "Edite `$__CGV2_Owner no topo de install-global-v2.ps1 com o seu usuario do GitHub."
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $url = "https://github.com/$Owner/$Repo/archive/refs/heads/$Branch.zip"
        $tempDir = Join-Path ([IO.Path]::GetTempPath()) ("cgv2-" + [Guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Force $tempDir | Out-Null
        $zip = Join-Path $tempDir "pkg.zip"
        Say "Baixando pacote: $url"
        Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
        Expand-Archive -Path $zip -DestinationPath $tempDir -Force
        $source = Get-ChildItem $tempDir -Directory -Recurse -Filter "global-v2" | Select-Object -First 1 -ExpandProperty FullName
        if (-not $source) { throw "Pasta global-v2 nao encontrada no pacote baixado." }
    }

    try {
        # ---- 2. Validar settings.json existente ANTES de mexer em qualquer coisa ----
        New-Item -ItemType Directory -Force $Target | Out-Null
        $settingsFile = Join-Path $Target "settings.json"
        $current = [pscustomobject]@{}
        if (Test-Path $settingsFile) {
            $rawSettings = ReadText $settingsFile
            if (-not [string]::IsNullOrWhiteSpace($rawSettings)) {
                try { $current = $rawSettings | ConvertFrom-Json }
                catch { throw "Seu $settingsFile nao e um JSON valido. Corrija-o e rode de novo (nada foi alterado)." }
            }
        }

        # ---- 3. Backup apenas do que este pacote gerencia ----
        $stamp  = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = Join-Path $Target "backups\global-v2-$stamp"
        $n = 1
        while (Test-Path $backup) { $backup = Join-Path $Target "backups\global-v2-$stamp-$n"; $n++ }
        New-Item -ItemType Directory -Force $backup | Out-Null
        foreach ($item in $Managed) {
            $p = Join-Path $Target $item
            if (Test-Path $p) { Copy-Item $p (Join-Path $backup $item) -Recurse -Force }
        }
        Say "Backup: $backup" Green

        # ---- 4. CLAUDE.md: bloco gerenciado entre marcadores (preserva conteudo pessoal) ----
        $begin = "<!-- BEGIN $Marker -->"
        $end   = "<!-- END $Marker -->"
        $block = "$begin`r`n" + (ReadText (Join-Path $source "CLAUDE.md")).Trim() + "`r`n$end"
        $globalFile = Join-Path $Target "CLAUDE.md"
        if (Test-Path $globalFile) {
            $old = ReadText $globalFile
            $pattern = "(?s)" + [regex]::Escape($begin) + ".*?" + [regex]::Escape($end)
            if ($old -match $pattern) {
                $new = [regex]::Replace($old, $pattern, { param($m) $block })
            } elseif ($old -match "(?m)^# Global engineering instructions\s*$") {
                # Versao 2.0 (sem marcadores): substitui do cabecalho ate o fim.
                $idx = ([regex]::Match($old, "(?m)^# Global engineering instructions\s*$")).Index
                $new = $old.Substring(0, $idx).TrimEnd() + "`r`n`r`n" + $block + "`r`n"
                Say "CLAUDE.md da versao 2.0 substituido (copia no backup)." Yellow
            } else {
                $new = $old.TrimEnd() + "`r`n`r`n" + $block + "`r`n"
            }
        } else {
            $new = $block + "`r`n"
        }
        WriteText $globalFile ($new.TrimStart())

        # ---- 5. Arquivos: rules, skills, agents, hooks (copia arquivo a arquivo) ----
        foreach ($folder in @("rules", "skills", "agents", "hooks")) {
            $srcDir = Join-Path $source $folder
            if (-not (Test-Path $srcDir)) { continue }
            Get-ChildItem $srcDir -Recurse -File | ForEach-Object {
                $rel  = $_.FullName.Substring($srcDir.Length).TrimStart('\', '/')
                $dest = Join-Path (Join-Path $Target $folder) $rel
                New-Item -ItemType Directory -Force (Split-Path -Parent $dest) | Out-Null
                Copy-Item $_.FullName $dest -Force
            }
        }
        foreach ($o in $Obsolete) {
            $p = Join-Path $Target $o
            if (Test-Path $p) { Remove-Item $p -Force }
        }

        # ---- 6. settings.json: mescla permissoes, modelo e hook ----
        $incoming = (ReadText (Join-Path $source "settings.template.json")) | ConvertFrom-Json

        if (-not (HasProp $current '$schema')) { SetProp $current '$schema' $incoming.'$schema' }
        if (-not (HasProp $current 'model'))   { SetProp $current 'model' $incoming.model }
        if (-not (HasProp $current 'permissions') -or $null -eq $current.permissions) {
            SetProp $current 'permissions' ([pscustomobject]@{})
        }
        $perm = $current.permissions
        if (-not (HasProp $perm 'defaultMode')) { SetProp $perm 'defaultMode' $incoming.permissions.defaultMode }
        $deny = New-Object System.Collections.Generic.List[string]
        foreach ($d in @($perm.deny) + @($incoming.permissions.deny)) {
            if ($d -and -not $deny.Contains([string]$d)) { $deny.Add([string]$d) }
        }
        SetProp $perm 'deny' ([string[]]$deny.ToArray())

        $hookPath = Join-Path $Target "hooks\guardrails.ps1"
        $guard = [pscustomobject]@{
            matcher = "Bash|PowerShell"
            hooks   = @([pscustomobject]@{
                type    = "command"
                command = "powershell.exe"
                args    = [string[]]@("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $hookPath)
                timeout = 15
            })
        }
        if (-not (HasProp $current 'hooks') -or $null -eq $current.hooks) { SetProp $current 'hooks' ([pscustomobject]@{}) }
        $groups = @()
        if (HasProp $current.hooks 'PreToolUse') { $groups = @($current.hooks.PreToolUse) }
        # remove registros antigos deste hook e registra a versao atual
        $groups = @($groups | Where-Object {
            $g = $_
            -not (@($g.hooks) | Where-Object { (@($_.args) -join ' ') -like '*guardrails.ps1*' -or [string]$_.command -like '*guardrails.ps1*' })
        })
        SetProp $current.hooks 'PreToolUse' (@($groups) + @($guard))

        $json = $current | ConvertTo-Json -Depth 100
        $null = $json | ConvertFrom-Json   # sanity check
        WriteText $settingsFile $json

        # ---- 7. Resumo ----
        $skills = (Get-ChildItem (Join-Path $source "skills") -Directory).Name
        $agents = (Get-ChildItem (Join-Path $source "agents") -File).BaseName
        $rules  = (Get-ChildItem (Join-Path $source "rules") -File).BaseName
        Say ""
        Say "Instalado em $Target" Green
        Say ("Skills : " + (($skills | ForEach-Object { "/$_" }) -join ", "))
        Say ("Agents : " + ($agents -join ", "))
        Say ("Rules  : " + ($rules -join ", "))
        Say "Hook   : guardrails.ps1 (Git write + SQL/migracoes bloqueados)"
        Say ""
        Say "Proximos passos:" Cyan
        Say "  1. Feche e reabra o VS Code / terminal."
        Say "  2. No Claude Code: /skills, /agents, /permissions, /hooks, /doctor."
        Say "  3. Para desfazer: copie de volta o conteudo de $backup"
    }
    finally {
        if ($tempDir -and (Test-Path $tempDir)) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

try {
    Install-ClaudeGlobalV2 -Owner $__CGV2_Owner -Repo $__CGV2_Repo -Branch $__CGV2_Branch -LocalRoot $__CGV2_LocalRoot
} catch {
    Write-Host ""
    Write-Host ("ERRO: " + $_.Exception.Message) -ForegroundColor Red
    Write-Host "Nada foi apagado. Se algo foi alterado, o backup esta em ~\.claude\backups\" -ForegroundColor Red
}
