---
paths:
  - "**/*.cs"
  - "**/*.csproj"
  - "**/*.sln"
  - "**/*.slnx"
---

# .NET / C#

- Detect target framework, C# version and solution architecture before suggesting APIs.
- Follow established naming, nullable-reference, DI, logging and error-handling conventions.
- Use async APIs for I/O and propagate CancellationToken where supported.
- Keep controllers/endpoints focused on transport concerns; preserve existing application/domain boundaries.
- Avoid pass-through repositories and services that add no meaningful abstraction.
- Dispose resources correctly; use using/await using where appropriate.
- Preserve public contracts and serialization behavior unless asked to change them.
- Add focused unit tests; never run database-backed tests or connect to Oracle/SQL Server.
