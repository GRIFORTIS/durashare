# Release Process

This document defines the maintainer release flow for `durashare`.
It is public process documentation, not part of the DuraShare protocol specification.

## Trust model
- The authoritative source-state attestation is a locally created signed git tag.
- Release assets are built and signed locally on the maintainer machine.
- GitHub Actions must not hold private signing keys for this repository.
- GitHub Releases are a distribution channel, not the root of trust.

## Release preflight
Before tagging, make sure all of the following are true on the target commit:
- CI is green.
- `CHANGELOG.md` has the intended dated release section at the top.
- `whitepaper/WHITEPAPER.tex` contains the same version in `\DuraShareVersion`.
- `test_vectors/vectors.json` contains the same `version`.
- `whitepaper/WHITEPAPER.pdf` builds successfully from the checked-in LaTeX source.

The current public signing key in this repo is:
- Fingerprint: `7921 FD56 9450 8DA4 020E 671F 4CFE 6248 C57F 15DF`
- UID: `GRIFORTIS <security@grifortis.com>`

## Local release asset build
From the repository root, choose the release version and build the whitepaper:

```bash
export VERSION="v0.7.1"
latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error -cd whitepaper/WHITEPAPER.tex
mkdir -p release-assets
cp whitepaper/WHITEPAPER.pdf "release-assets/WHITEPAPER.pdf"
cp whitepaper/WHITEPAPER.pdf "release-assets/WHITEPAPER-${VERSION}.pdf"
(cd release-assets && sha256sum WHITEPAPER.pdf "WHITEPAPER-${VERSION}.pdf" > CHECKSUMS.txt)
./scripts/verify-checksums.sh --local release-assets/CHECKSUMS.txt
```

`CHECKSUMS.txt` must list the published asset names (`WHITEPAPER.pdf` and `WHITEPAPER-${VERSION}.pdf`), not local staging paths.

## Local detached signatures
Create detached ASCII-armored signatures locally:

```bash
gpg --armor --detach-sign "release-assets/WHITEPAPER.pdf"
gpg --armor --detach-sign "release-assets/WHITEPAPER-${VERSION}.pdf"
gpg --armor --detach-sign "release-assets/CHECKSUMS.txt"
```

Then verify them immediately:

```bash
gpg --verify "release-assets/WHITEPAPER.pdf.asc" "release-assets/WHITEPAPER.pdf"
gpg --verify "release-assets/WHITEPAPER-${VERSION}.pdf.asc" "release-assets/WHITEPAPER-${VERSION}.pdf"
gpg --verify "release-assets/CHECKSUMS.txt.asc" "release-assets/CHECKSUMS.txt"
(cd release-assets && sha256sum -c CHECKSUMS.txt)
```

## Signed tag
The git tag is the repository-state attestation and must be OpenPGP-signed as `GRIFORTIS <security@grifortis.com>` so GitHub can verify it against the uploaded GRIFORTIS key. Do not change the repository `git config`; pass the identity for this command only. Commits remain SSH-signed.

```bash
git -c gpg.format=openpgp \
  -c user.signingkey=7921FD5694508DA4020E671F4CFE6248C57F15DF \
  -c user.name="GRIFORTIS" \
  -c user.email="security@grifortis.com" \
  tag -s "${VERSION}" -m "Release ${VERSION}"
git tag -v "${VERSION}"
```

Push the tag only after verification succeeds:

```bash
git push origin "${VERSION}"
```

## GitHub publishing
After the signed tag is on the remote:
1. Create a GitHub Release manually from the pushed tag.
2. Upload these local files from `release-assets/`:
   - `WHITEPAPER.pdf`
   - `WHITEPAPER.pdf.asc`
   - `WHITEPAPER-${VERSION}.pdf`
   - `WHITEPAPER-${VERSION}.pdf.asc`
   - `CHECKSUMS.txt`
   - `CHECKSUMS.txt.asc`
3. Run Release Verify after publishing. It must be green before the release is announced:

```bash
./scripts/verify-published-release.sh "${VERSION}"
```

That check requires all six assets, `VALIDSIG` under the pinned GRIFORTIS fingerprint, fail-closed checksums, and identical PDF pair bytes.

## Final spot-check
After publishing:
1. Download the release assets from GitHub.
2. Verify the detached signatures with the public key.
3. Verify `CHECKSUMS.txt`.
4. Verify the signed git tag with `git tag -v`.
5. Confirm GitHub shows the tag as Verified (`verification.reason=valid`).

See [`docs/release-verification.md`](docs/release-verification.md) for the public-facing verification walkthrough.

## Notes
- If CI fails, fix the commit and rerun CI before tagging.
- If local signing fails, do not push the tag.
- If a release upload fails after the tag is published, the signed tag remains the trusted release anchor; re-upload the already signed assets rather than rebuilding from a different commit.
