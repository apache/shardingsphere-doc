# Repository Guidelines

## Project Structure & Module Organization
- `document/<version>/` holds generated ShardingSphere docs per release; `document/current/` is the latest; `legacy*` keeps earlier snapshots.
- `elasticjob/current/` and `oncloud/current/` are the ElasticJob and On-Cloud sites; `blog/`, `community/`, `statistics/`, `benchmark/`, and `charts/` support the site.
- Root `index.html` plus `style/`, `js/`, `images/`, and `fonts/` form the marketing homepage; keep paths stable because external links rely on them.
- `.github/scripts/` contains automation for site builds, PDFs, and Maven reports; `versions.json` drives the docs version switcher.
- Most content is generated from upstream repos (`apache/shardingsphere`, `apache/shardingsphere-elasticjob`, `apache/shardingsphere-on-cloud`); prefer editing upstream sources, then rebuild here.

## Build, Test, and Development Commands
- `bash .github/scripts/build-website.sh` clones upstream repos, runs Hugo 0.83.1 via their `build.sh`, and refreshes `document/current`, `community/`, `blog/`, `elasticjob/current`, and `oncloud/current`; start with a clean tree.
- `bash .github/scripts/generate-pdf.sh` (Python 3.8, Sphinx, Pandoc, TeXLive) regenerates PDFs into `pdf/`.
- `bash .github/scripts/build-maven-report.sh $(pwd)` clones `apache/shardingsphere`, runs `./mvnw ... site:stage`, and replaces `statistics/staging/`.
- Preview static tweaks with `python -m http.server 8000` from repo root.

## Coding Style & Naming Conventions
- HTML/CSS/JS assets use two-space indentation, lowercase filenames, and no bundler; keep scripts compatible with existing jQuery/Hugo output.
- Shell scripts are Bash; favor `set -e` when altering build steps, keep variables lowercase with descriptive names, and avoid hardcoded user-specific paths.
- Keep assets ASCII-only unless the file already uses other glyphs (fonts under `fonts/` are the main exception).

## Testing Guidelines
- After modifying static pages, load them locally (see `python -m http.server`) and check navigation links, version dropdowns, and image paths.
- When touching build scripts, rerun the relevant script (`build-website.sh`, `generate-pdf.sh`, or `build-maven-report.sh`) and confirm outputs land in the expected directories.
- No automated tests exist; document manual checks in your PR.

## Commit & Pull Request Guidelines
- Follow the existing imperative, descriptive style (e.g., `Update shardingsphere documents at <timestamp>.`); keep subject lines under ~72 chars.
- Each PR should note the area touched (homepage assets, docs sync, PDF, Maven report), the commands run, and any upstream issues it relates to.
- Include before/after screenshots for visual changes and list regenerated artifacts; avoid committing caches or temporary files.

## Security & Configuration Tips
- Do not commit credentials or tokens; automation clones public repos and sets git identity inside scripts.
- Large binaries (fonts, PDFs) are already tracked—avoid adding new ones unless required and documented.
