# Review & Feedback

DuraShare modifies existing, well-established cryptographic techniques for human-executable threshold backup. Reference implementations are thoroughly tested, published as-is, and have not been independently audited.

Technical feedback is welcome from cryptographers, wallet architects, implementers, custody practitioners, and people who have run real-world key-backup ceremonies.

Treat the whitepaper, `manual_spec/`, `software_spec/`, and `test_vectors/` as the primary review targets. Implementation repositories should declare explicit spec/vector support before being treated as conformant.

## High-Value Review Targets

- **Arithmetic confidentiality**: Shamir/LSSS secrecy over unrestricted `GF(2053)` shares, including deterministic row, column, and GIC fields.
- **Linear consistency layer**: the `d = 4` product-code argument, passive-error detection, and single-error repair-candidate claim.
- **Per-share audit**: Share Audit ceremony, MAT construction, Manifest Audit Hash model, and the exact compromise conditions for each check.
- **MAT security**: the `1/2053` per-column false-accept bound, Split-Key Manifest reasoning, and what MAT does not authenticate.
- **RBT / RVA separation**: RBT as protocol-object binding and RVA as wallet-context verification.
- **Full / Compact profiles**: Full complete-table serialization, Compact word-only serialization, Transport Hash omission in Compact, and paper-table recomputation requirements.
- **Manual fallback**: recovery procedure, BIP39 language handling, out-of-range field-element rendering, Lagrange coefficients, and expected operator checkpoints.
- **Threat model**: trusted devices/peripherals, assisted ceremonies, durable artifacts, inheritance scenarios, and denial/replacement attacks.
- **Test vectors**: v0.7.0 arithmetic, payload bytes, RBT, Transport Hash, Manifest Audit Hash, MAT, and recovery values.

## Secondary Review Targets

- **DRK resume mode**: HMAC-SHA256 coefficient derivation and the shift from information-theoretic to computational coefficient generation for that mode.
- **QR workload claims**: structural hand-mark counts for Full vs Compact and whether the assumptions are clear.
- **Printer/output tiers**: whether secret-bearing and non-secret-but-sensitive output boundaries are understandable.
- **Recursive composition**: whether layer semantics, metadata, and MAT independence are clear.

## Out of Scope Here

- Treating non-conformant implementations as references.
- Operational deployment recommendations for real funds.
- UI polish unrelated to safety, recoverability, or auditability.
- Hardware manufacturing details for manual RNG tools.

## How to Contribute Feedback

Open an issue in the spec repo:

- **Spec review**: protocol/spec clarity and correctness.
- **Security analysis**: threat model, proofs, and security properties.
- **Implementation conformance**: software spec, payloads, RBT, and vectors.
- **Operational model**: custody workflows, recovery context, artifact handling, and audit procedures.

Pull requests are welcome for `manual_spec/`, `software_spec/`, `test_vectors/`, docs, and the whitepaper.

## Proposal-First for Behavior Changes

If you propose a protocol behavior change, start with a proposal in [`../proposals/`](../proposals/).
