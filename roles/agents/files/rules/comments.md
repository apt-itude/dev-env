# Comments & descriptions must be durable

Applies to every kind of authored comment or description, in any language or format: code
comments, docstrings, Terraform/HCL `description` fields, YAML/Helm comments, config annotations,
JSON `"description"` values, etc. (Not commit messages, PR descriptions, or review replies — those
are point-in-time by nature.)

**Principle:** a comment states the *enduring* why — the purpose, contract, invariant, or a
non-obvious reason. It must not encode transient state that will be false once the current work
lands or the rollout finishes. If a reader six months from now would find the comment misleading
or stale, don't write it.

**Never** put point-in-time state in a comment. Banned phrasings (non-exhaustive):
- rollout/sequencing: "for now", "rolling out", "dev first", "then staging/prod", "next step",
  "will be enabled", "temporarily", "soon", "eventually", "once X is done"
- recency: "currently", "recently", "new", "used to", "was previously"
- process/scaffolding: ticket IDs (PINF-123), "this ticket", "scaffolded", "placeholder",
  "TODO after merge", "WIP"

**Where transient state actually belongs** — not a comment:
- which environments a flag is on → the tfvars / config values themselves (that's the source of truth)
- what's coming next → the issue tracker (Linear/GitHub), not the code
- why a value is what it is *durably* → fine to state the reason, just not the timeline

**Litmus test:** would this sentence still be accurate after the change ships and the rollout
completes? If no, delete it or rewrite it to the durable reason.

```
# bad  — describes a moment in time
description = "Enable metrics. Rolling out per-environment (dev first)."
# good — describes the durable purpose; the per-env choice lives in tfvars
description = "Whether to enable the controller's Prometheus metrics endpoint."

# bad
# TODO: remove once PINF-847 lands; scaffolded for now
# good
# The agent's ConfigMap omits METRICS_BIND_ADDRESS, so the metrics server is off unless set here.
```
