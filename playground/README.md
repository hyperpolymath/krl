# KRL Playground

A local PWA playground for KRL (Knot Resolution Language, pronounced "curl").

## Status

**Scaffold only.** KRL itself is at CRG grade X (no grammar/parser yet).
This playground will follow the language implementation.

## Intended architecture

- **Backend:** KRL source → KRLAdapter.jl (for TangleIR + Skein persistence)
- **Runtime:** Deno server calling Julia via stdin/stdout or HTTP to a
  `KRLAdapter.jl`-powered service
- **UI:** ReScript + React SPA with Monaco editor configured for KRL syntax
- **Execution modes:**
  - `parse` — show AST
  - `typecheck` — boundary arity check, port compatibility
  - `compile` — TangleIR output
  - `invariants` — compute Jones, Alexander, determinant, signature via KRLAdapter
  - `store` — persist to in-memory Skein DB; show query results
  - `visualise` — render the compiled tangle diagram
- **Share-by-URL:** URL-encoded KRL source

## Directory layout

```
playground/
├── README.md         (this file)
├── public/           (PWA shell when built)
└── examples/         (starter .krl programs)
```

## Next steps

This playground is blocked on KRL reaching grade E (grammar + 1 smoke test).
See repo-level `READINESS.md` for the KRL implementation path.

See sibling playgrounds for patterns:
- `/var/mnt/eclipse/repos/nextgen-languages/eclexia/playground/`
- `/var/mnt/eclipse/repos/nextgen-languages/betlang/playground/`
