# Schiavinato Sharing Security Model

This is a non-normative security overview for reviewers and implementers. The whitepaper is authoritative for analysis, `manual_spec/` is authoritative for manual arithmetic and Share Audit, and `software_spec/` is authoritative for digital-envelope behavior.

## Scope

Schiavinato Sharing protects BIP39 word indices with standard Shamir sharing over `GF(2053)`. It adds:

- public row, column, and GIC checks for passive error detection;
- optional MAT for bounded manual pre-recovery substitution detection;
- Manifest Audit Hashes for computational per-share commitments;
- RBT and RVA for post-recovery warning checks.

The protocol is for cold-storage backup and disaster recovery. It is not a spending policy, online authentication system, MPC wallet, multisig replacement, or substitute for physical custody controls.

## In Scope

- Passive arithmetic, transcription, scanning, media-corruption, and share-number errors.
- Accidental mixing of shares from different sessions.
- Pre-recovery substitution detection when MAT keys remain secret or an uncompromised Manifest Audit Hash is available.
- Post-recovery wrong-object detection via RBT.
- Post-recovery wallet-context detection via RVA.
- Manual recovery when the original software stack is unavailable.

## Out of Scope

- Compromise of `k` or more valid Shares.
- Compromised devices or peripherals that observe secret-bearing material.
- Physical coercion, social engineering, or loss of all recovery context.
- Compromise of the BIP39 or wallet ecosystem.
- A compromised Manifest used as the only audit anchor.
- Malicious dealers who intentionally generate bad artifacts.

## Confidentiality

The arithmetic Share layer provides standard Shamir/LSSS confidentiality for any coalition holding fewer than `k` arithmetic Shares. Row checksums, column checksums, and GIC values are deterministic affine functions of field elements already present on the same Share, so they add no independent information to an unauthorized view.

MAT tags and keys are outside the arithmetic Share. MAT keys are independent randomness: complete keys enable forgery of the matching MAT tags but reveal no mnemonic information.

Hand-Transcribed QR resume derives coefficients from a 256-bit DRK using HMAC-SHA256. That resume mode shifts coefficient generation from information-theoretic randomness to a computational PRF assumption. Other resume modes use true-random coefficient material.

## Passive Error Detection

The public consistency layer detects arithmetic mistakes, transcription errors, damaged cells, and accidental share-number mixups.

The whitepaper proves minimum distance `d = 4`: every passive error pattern affecting up to three cells is detected. Under an explicit single-error assumption, the syndrome identifies a unique repair candidate. These checks are not authentication: an adversary who can rewrite an entire Share can recompute public checks.

## Per-Share Audit

Share Audit validates one physical Share before recovery, without combining Shares or reconstructing the mnemonic.

Available checks depend on artifacts:

- Public row/column/GIC checks detect passive corruption.
- MAT verifies printed word rows when the matching MAT keys are available and uncompromised.
- Manifest Audit Hashes commit to Payload bytes when a separate Manifest is available.
- Full Payloads allow complete canonical arithmetic-table comparison.
- Compact Payloads require word-value comparison followed by recomputation against the printed row, column, and GIC fields.

An unresolved Share Audit mismatch is STOP. A failed Share is never edited, retagged, or resubmitted with altered values.

## Digital Envelope Integrity

Full includes a 16-byte Transport Hash over the Full Payload prefix and fields before the hash. A mismatch is STOP.

Compact omits the Transport Hash. Its smaller QR shifts more verification work back to the printed artifact: software recomputes checks from scanned word-share values and compares against the paper table.

Manifest Audit Hashes are commitments to one Share Payload. They detect substitution only while the Manifest record remains uncompromised. An adversary who can alter both a Share Payload and its Manifest Audit Hash can defeat that computational commitment.

## Post-Recovery Checks

After interpolation produces a candidate protocol object:

- BIP39 checksum detects invalid recovered mnemonics in BIP39 mode.
- RBT checks whether the recovered protocol object matches the original session binding.
- RVA checks intended wallet context, including derivation settings and optional BIP39 passphrase when applicable.

RBT and RVA are warning layers. They do not replace Shamir confidentiality or MAT/Manifest pre-recovery audit.

## Manifest Rules

Manifests are operationally useful but sensitive. They may contain:

- session metadata;
- RBT references;
- per-share Audit Hashes;
- custody notes;
- wallet-context hints;
- Whole-Key MAT material or Split-Key MAT halves.

Manifests MUST NOT contain plaintext Share values. They SHOULD NOT contain printed GIC maps.

Whole-Key MAT Manifest sections are secret material. A single Split-Key half reveals no complete MAT key, but it can be withheld or corrupted to cause denial.

## Operational Trust Boundary

Any device or peripheral that handles secret-bearing material is in scope for trust:

- air-gapped ceremony device;
- printer or display used for secret-bearing output;
- scanner/camera used for secret-bearing input;
- calculator used for manual secret arithmetic;
- storage media holding decrypted resume material or MAT keys.

Peripherals that handle only blank templates or non-secret metadata are outside the secret-handling boundary, though their output may still be operationally sensitive.

## Validation Pipeline Summary

Typical recovery validation order:

1. Validate each physical Share with row/column/GIC checks.
2. Run Share Audit when MAT or Manifest Audit Hashes are available.
3. Check set-level metadata consistency.
4. Interpolate using Lagrange coefficients.
5. Validate recovered rows, columns, and base GIC.
6. Convert recovered indices using the printed BIP39 wordlist language.
7. Validate BIP39 checksum.
8. Recompute RBT when payload metadata is available.
9. Verify RVA when recorded.

## References

- [`../whitepaper/WHITEPAPER.tex`](../whitepaper/WHITEPAPER.tex)
- [`../manual_spec/README.md`](../manual_spec/README.md)
- [`../software_spec/README.md`](../software_spec/README.md)
- [`../test_vectors/README.md`](../test_vectors/README.md)
