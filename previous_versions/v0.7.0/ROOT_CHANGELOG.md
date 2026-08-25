# Changelog

All notable changes to the Schiavinato Sharing specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.0] - 2026-07-23

### Changed
- Active docs and specs now use Full / Compact Output Profile terminology.
- Compact is documented with 12-bit share packing and smaller envelope metadata.
- Hand Transcribed QR resume now uses a Deterministic Resume Key (DRK) for HMAC-SHA256 coefficient derivation.
- All four resume modes are documented as available under both Output Profiles.
- Root test vectors now target v0.7.0, including Full and Compact payloads, RBT, Transport Hash, Manifest Audit Hash, deterministic MAT sample data, and recovery values.

### Removed
- Removed current-protocol Reduced Mode rejection, 11-bit word-share packing, rejection-pool, and per-position derivation claims from active docs/specs.

## [0.6.0] - 2026-05-10

### Added
- Canonical `v0.6.0` live vectors for the public 12-word 2-of-3 mnemonic.
- Reduced Mode vector session demonstrating coefficient rejection, accepted replacement coefficients, 11-bit word-share packing, 12-bit printed GIC packing, and truncated Audit Hashes.
- Frozen vectors snapshot for `v0.5.0` under `previous_versions/v0.5.0/test_vectors/`.
- Non-normative v0.6.0 software implementation flow diagrams under `docs/software-flows/`.
- Expanded whitepaper sections for peer review, including background and related work, system/threat model, computational deployment and verification, evaluation and reproducibility, and deployment/artifact trust boundaries.

### Changed
- Per-share Audit QR payloads now include the protocol version byte: `SA || version || k || x || hash`.
- Live vector metadata now targets `v0.6.0` to match the whitepaper version.
- Implementation language now frames the HTML, JavaScript/TypeScript, and Python repositories as in-progress prototypes that may lag the v0.6.0 specification.
- `software_spec/README.md` now reflects the v0.6.0 software-assisted ceremony model, including trust boundaries, resume artifact lifecycle, coefficient sourcing and Reduced Mode rejection, artifact rendering, audit drills, printer tiers, cleanup, and validation semantics.
- Coefficient generation now samples each Shamir coefficient from the full field range `0..2052`, without forcing the highest-power coefficient to be nonzero. Reduced Mode keeps that coefficient source and rejects word polynomials whose evaluated word-share values exceed `2047`.
- `docs/security-model.md` was rewritten as a concise current security overview aligned with the manual spec, software spec, manifest audit model, BI/RVA checks, and printer/resume trust boundaries.
- Release workflow and verification examples now target `v0.6.0`.

## [0.5.0] - 2026-04-09

### Added
- Frozen release archive root: `previous_versions/`.
- Partial vectors-only archive snapshot for `v0.4.0`: `previous_versions/v0.4.0/test_vectors/`.
- Canonical vectors set for the archived v0.4.1 snapshot: `previous_versions/v0.4.1/test_vectors/`.
- Live current-protocol vectors at `test_vectors/vectors.json` and `test_vectors/vectors.md`.
- Canonical `v0.5.0` Full Mode test vector for the public 12-word 2-of-3 mnemonic, including position-bound row checksums, column checksums, printed GIC, and manifest/audit QR artifacts.
- Issue template contact links via `.github/ISSUE_TEMPLATE/config.yml` (Discussions + private security reporting).

### Changed
- Centralize community health references (SECURITY / CONTRIBUTING) to the org-wide defaults in `GRIFORTIS/.github`.
- Issue templates and research docs updated to link to the org-wide SECURITY / CONTRIBUTING policies.
- Root `whitepaper/` is now treated as the latest-only location for `WHITEPAPER.tex` and `WHITEPAPER.pdf`; older whitepaper versions belong in archives or release assets.
- Whitepaper release handling now uses local maintainer signing, signed git tags, and manual GitHub publishing; Actions no longer import private signing keys and now verify published release assets instead.
- Historical v0.4.1 artifacts now live under `previous_versions/v0.4.1/` instead of mixed root-level versioned file paths.
- Live `test_vectors/` layout is now flat within `test_vectors/`; archived releases remain flat under `previous_versions/vX.Y.Z/test_vectors/`.
- CI and gitleaks now validate the root-level live vectors layout instead of the older `test_vectors/vX.Y.Z/` live-folder design.
- Spec clarifications and alignment for implementers:
  - `manual_spec/README.md`: expanded recovery-first manual procedure, normalized human-readable index conventions, and clarified constraints and validation semantics.
  - `software_spec/README.md`: clarified the v0.5.0 wire format, core payload byte layout, share-data packing rules, and decode/validation pipeline.
  - `docs/security-model.md`: clarified transport-hash truncation, STOP/WARN semantics, and encoding/validation steps.
- Whitepaper links updated to reference the org-wide security policy.

### Removed
- Repo-local community health duplicates under `.github/` (CODE_OF_CONDUCT, CONTRIBUTING, SECURITY, PR template) in favor of the org-wide defaults.

## [0.4.1] - 2026-02-03

### Added
- Strict whitepaper release automation: build LaTeX → PDF and publish both a stable `WHITEPAPER.pdf` and a versioned `WHITEPAPER-vX.Y.Z.pdf` (with checksums + GPG signatures).
- CI hardening: secret scanning, workflow linting, relative-link checks, and LaTeX build verification.

### Changed
- Content alignment across docs and links (whitepaper links now include both latest and versioned releases).

## [0.4.0] - 2026-01-27

### Added
- **Whitepaper publication**: Complete technical specification (LaTeX source and PDF)
- **Preliminary validation study**: Manual recovery feasibility results (4 participants, 2 trials)
- **Security validation experiments**: Entropy conservation and adversarial constraint solving
- Dual-path checksum validation (Path A direct sums, Path B polynomial-based) in reference HTML split/recover flows to detect hardware faults and bit flips
- New checksum polynomial helpers: `sumPolynomials`, `computeRowCheckPolynomials`, `computeGlobalIntegrityCheckPolynomial`
- Error reporting now surfaces path mismatches (`rowPathMismatch`, `globalPathMismatch`)
- **GIC Binding**: Global Integrity Check is now bound to share number `x` (printed GIC = sum + x mod 2053)

### Changed
- Split now constructs checksum polynomials and requires agreement between Path A and Path B for every share
- Recovery keeps backward-compatible error reporting while flagging path disagreement explicitly
- UI messaging highlights path mismatches separately from standard checksum failures
- **Terminology standardization**: "Global Checksum" renamed to "Global Integrity Check (GIC)" across all code, tests, and documentation

### Compatibility
- No share-format changes; existing shares remain recoverable
- New error fields are additive

## [0.3.0] - 2025-12-05

### Changed
- Checksum shares are now computed deterministically as the sum of word shares (mod 2053) rather than using independent random polynomials
- This change enables share integrity validation during the splitting process
- Recovery algorithm unchanged - all existing shares remain recoverable
- Maintains all LSSS security properties

### Benefits
- Users can verify share integrity during manual splitting
- Row checksum share = sum of 3 word shares in that row (mod 2053)
- Global Integrity Check (GIC) share = sum of all word shares (mod 2053)
- Catches arithmetic errors before share distribution
- Zero impact on recovery time or process

### Security Note
- No information leakage (checksums are deterministic functions of words)
- Threshold property preserved (still requires k shares for recovery)
- Entropy source unchanged (word polynomials remain random)

## [0.2.0] - 2025-11-30

### Added
- Comprehensive test suite for reference implementation (Playwright)
- CI/CD workflows for automated testing
- SHA256 checksum generation for releases
- Verification scripts for Linux/macOS and Windows
- Complete documentation structure

## [0.1.0] - 2025-11-27

### Added
- Initial whitepaper
- Test vectors for validation
- Contributing guidelines
- Security policy
- Issue templates

### Status
- **Security**: Experimental - not audited
- **Recommendation**: For testing and review only

---

## Review & contribution
- Review entry point: `docs/review.md`
- Proposals: `proposals/`
- Vectors: `test_vectors/`

## Links
- **Repository**: [schiavinato-sharing](https://github.com/GRIFORTIS/schiavinato-sharing)
- **HTML implementation**: [schiavinato-sharing-html](https://github.com/GRIFORTIS/schiavinato-sharing-html)
- **JavaScript/TypeScript implementation**: [schiavinato-sharing-js](https://github.com/GRIFORTIS/schiavinato-sharing-js)
- **Python implementation**: [schiavinato-sharing-py](https://github.com/GRIFORTIS/schiavinato-sharing-py)
- **Organization**: [GRIFORTIS](https://github.com/GRIFORTIS)

[Unreleased]: https://github.com/GRIFORTIS/schiavinato-sharing/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/GRIFORTIS/schiavinato-sharing/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/GRIFORTIS/schiavinato-sharing/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/GRIFORTIS/schiavinato-sharing/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/GRIFORTIS/schiavinato-sharing/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/GRIFORTIS/schiavinato-sharing/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/GRIFORTIS/schiavinato-sharing/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/GRIFORTIS/schiavinato-sharing/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/GRIFORTIS/schiavinato-sharing/releases/tag/v0.1.0

