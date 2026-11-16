---
paths:
  - "**/*.sql"
  - "**/*.pks"
  - "**/*.pkb"
  - "**/Migrations/**"
  - "**/migrations/**"
---
# SQL (Oracle / SQL Server)
- Never execute SQL, connect to a database or run migrations; produce text only.
- Detect the dialect (Oracle PL/SQL vs T-SQL) from the files before writing.
- Use bind parameters; never concatenate user input into SQL.
- Prefer set-based queries; avoid cursors/loops and N+1 patterns when a join works.
- Avoid SELECT * and unbounded queries; paginate large reads.
- Mark any DML/DDL clearly and include the rollback consideration.
- Do not alter existing migrations; new schema changes go in new migration files, only when asked.
