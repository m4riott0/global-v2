$ErrorActionPreference = "Stop"

function Deny([string]$reason) {
    @{
        hookSpecificOutput = @{
            hookEventName            = "PreToolUse"
            permissionDecision       = "deny"
            permissionDecisionReason = $reason
        }
    } | ConvertTo-Json -Depth 5 -Compress
    exit 0
}

try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }
    $inputObject = $raw | ConvertFrom-Json
    $command = [string]$inputObject.tool_input.command
    if ([string]::IsNullOrWhiteSpace($command)) { exit 0 }

    # git [global options] <write-subcommand>
    $gitOpts  = '(?:\s+(?:-C\s+\S+|-c\s+\S+|--git-dir(?:=|\s+)\S+|--work-tree(?:=|\s+)\S+|-{1,2}[^\s]+))*'
    $gitWrite = '(?i)\bgit(?:\.exe)?' + $gitOpts + '\s+(?:commit|push|pull|merge|rebase|cherry-pick|reset|clean|revert|checkout|switch|restore|stash|tag|am|worktree|filter-branch|filter-repo|update-ref|replace|notes|gc|prune)\b'
    $gitBranchWrite = '(?i)\bgit(?:\.exe)?' + $gitOpts + '\s+branch\s+(?:.*\s)?-(?:d|D|m|M|f|-delete|-move|-force)\b'

    $sqlTools = '(?i)\b(?:sqlcmd|sqlplus|sqlcl|sqlldr|impdp|expdp|Invoke-Sqlcmd|Invoke-DbaQuery|sqlpackage|psql|mysql|mongosh|mongo|sqlite3|flyway|liquibase)\b'
    $migrations = '(?i)\bdotnet[\s-]+ef\s+(?:database|migrations\s+(?:script|bundle))\b|\bprisma\s+(?:migrate|db)\b|\bdrizzle-kit\s+(?:push|migrate)\b|\bknex\s+(?:migrate|seed)\b|\bsequelize(?:-cli)?\s+db:|\btypeorm(?:-ts-node-\w+)?\s+(?:migration:run|migration:revert|schema:sync|schema:drop|query)\b'

    if ($command -match $gitWrite -or $command -match $gitBranchWrite) {
        Deny "Blocked by personal policy: Git write/history operations are reserved for the developer. Read-only git status/diff/log/show is allowed."
    }
    if ($command -match $sqlTools -or $command -match $migrations) {
        Deny "Blocked by personal policy: database clients, SQL execution and migration tools are not allowed."
    }
    exit 0
}
catch {
    # Fail closed if the guard cannot parse its input.
    Deny "Safety hook failed to parse command input; command blocked."
}
