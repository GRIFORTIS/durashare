# software_spec changelog

All notable changes to `software_spec` will be documented here.

## [Unreleased]

## [0.7.0] - 2026-07-23

### Changed
- Renamed the active payload distinction from Full Mode / Reduced Mode to Full / Compact Output Profiles.
- Rebuilt the software specification around the v0.7.0 digital envelope: `SF` / `SC` Payloads, Language/Input byte, RBT, Full complete-table serialization, Compact word-only serialization, and Manifest Audit Hash checks.
- Full now serializes the complete canonical arithmetic Share table; Compact serializes word-share values only and recomputes row, column, and GIC checks against the printed artifact.
- Compact now uses 12-bit word-share packing and smaller envelope metadata.
- Blinded Identity / MKI terminology has been replaced by the Recovery Binding Tag (RBT) model.
- Manifests are now specified without printed GIC maps; MAT key material and Manifest Audit Hashes remain separate from plaintext Share values.
- Hand Transcribed QR now uses a 256-bit Deterministic Resume Key (DRK) for HMAC-SHA256 coefficient derivation over public ceremony context.
- Resume modes are orthogonal to Output Profile: Digital Resume, Hand Transcribed Table, Hand Transcribed QR, and No Resume are available under both Full and Compact.

### Removed
- Removed current-protocol Reduced Mode sample rejection, rejection pools, 11-bit word-share packing, and per-word Position re-derivation.
- Removed Blinded Identity / MKI from the active v0.7.0 software specification.

## [0.6.0] - 2026-05-10

### Added
- Software-assisted ceremony boundary: Air-Gapped App / Companion App trust split and artifact handling rules.
- Artifact class and metadata placement guidance for arithmetic share content, share-local recovery metadata, and manifest-only/session metadata.
- Resume mode specification for Digital Resume, Hand Transcribed Table, Hand Transcribed QR, and No Resume.
- Resume artifact encryption envelope guidance, including Argon2id/scrypt KDF options, XChaCha20-Poly1305/AES-256-GCM encryption options, authenticated context, and STOP semantics on authentication failure.
- Coefficient sourcing and Reduced Mode rejection rules, including deterministic Single-Entropy HMAC derivation for Hand Transcribed QR.
- Share rendering, transcription validation, manifest audit drill, printer-tier output rules, cleanup, and best-effort memory handling guidance.
- Manifest security notes covering operational sensitivity, Audit Hash commitments, and GIC-map leakage bounds.
- RVA warning-resolution scan and draft-session edit/reset behavior.

### Changed
- Per-share Audit QR payloads now include the protocol version byte: `SA || version || k || x || hash`.
- Runtime integrity assertion is now a MUST before print/export/transcription.
- Software specification header now targets v0.6.0.
- Coefficient sourcing now uses the full field range `0..2052` without a nonzero highest-power requirement. Reduced Mode applies its compact range rule by rejecting word polynomials whose evaluated word-share values exceed `2047`.

## [0.5.0] - 2026-04-09

### Added
- **Reduced Mode** payload profile: 11-bit word packing, 4-byte Batch ID, 8-byte BI, no Transport Hash, QR V3 with `SC` prefix, up to 2 nesting layers.
- **Full Mode / Reduced Mode** distinction throughout. Full Mode is the primary profile for long-term custody; Reduced Mode is an accessible alternative.
- **Manifest QR payloads**: Manifest Header QR (`SM` prefix) and per-share Audit QR (`SA` prefix) with SHA-256 integrity commitment.
- **Runtime integrity assertion** (Path A vs Path B double-check) as a SHOULD-level recommendation.
- **Optional text export** noted as intentionally unspecified.
- Verification architecture summary for Full Mode and Reduced Mode.
- RVA verification step in the decode pipeline.

### Changed
- **Master Key Identifier**: now uses the full 20-byte HASH160 of the compressed master public key (was 4-byte BIP32 fingerprint). The 20-byte key ensures the HMAC key space is not the security bottleneck.
- **Full Mode Blinded Identity**: 12 bytes / 96 bits (was 8 bytes / 64 bits).
- **Full Mode payload offsets**: BI at offset 14 is now 12 bytes, shifting Share Data to offset 26 (was offset 22). Total core payload is 42 + share_data_len (was 38 + share_data_len).
- **Share data contents**: now serializes word values + printed GIC only. Row and column checksums are **not** serialized in the digital envelope (they are computed from share data for human-readable display). Element count is \(\ell + 1\) (was \(\ell + r + 1\)).
- **QR prefix decode rule**: now distinguishes `SCHI` (Full Mode) from `SC` (Reduced Mode).
- **Decode pipeline**: expanded to 10 steps including manifest audit, RVA verification, and mode-aware transport validation.

### Breaking
- Full Mode payload layout is incompatible with v0.4.x due to changed BI size, changed share data contents, and changed offsets.
- MKI derivation uses 20-byte HASH160 instead of 4-byte fingerprint; Blinded Identity values will differ even for the same mnemonic.
- Existing v0.4.x payloads are **not** decodable as v0.5.0.

## [0.4.1] - 2026-02-03
- Initial published draft (single mode, 4-byte fingerprint, 8-byte BI, words + row checksums + GIC in share data).
