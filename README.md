# Hermes Ecommerce Skills

Reusable ecommerce research skills and bundles for [Hermes Agent](https://github.com/NousResearch/hermes-agent).

This repo currently focuses on **Amazon product research / product selection**: competition heat, trends, reviews, competitor strategy, content-platform validation, profit assumptions, compliance/IP risks, and HTML report delivery.

## What is included

```text
hermes-ecommerce-skills/
├── README.md
├── bundles/
│   └── product-research.yaml
└── ecommerce/
    └── amazon-product-research-assistant/
        ├── SKILL.md
        └── references/
            ├── asin-deep-dive-notes.md
            ├── asset-collection-notes.md
            ├── html-report-template-notes.md
            └── product-research-bundle-notes.md
```

## Skill: `amazon-product-research-assistant`

A multi-agent Amazon product research skill for product selection and ecommerce opportunity analysis.

It helps analyze:

- Amazon competition heat and competitor links
- Google Trends 1-year / 5-year trend checks
- Review pain points and product improvement opportunities
- Competitor positioning and weak-listing opportunities
- YouTube / TikTok / social content validation
- Supply chain, profit, compliance, and IP risks
- HTML report delivery with product images and data sources

## Bundle: `/product-research`

The bundle is a shortcut command that loads the main ecommerce skill plus supporting skills:

```yaml
skills:
  - amazon-product-research-assistant
  - subagent-driven-development
  - youtube-content
  - html-artifact-generation
```

The bundle instruction tells Hermes to use multi-agent lanes when available:

- Amazon competition
- Google Trends / API-data gap
- Reviews and pain points
- Competitor strategy
- Profit / FBA / compliance / IP risks
- YouTube / TikTok / social demand
- Final synthesis and HTML report

## Install the skill

Install directly from GitHub:

```bash
hermes skills install https://raw.githubusercontent.com/flying864/hermes-ecommerce-skills/main/ecommerce/amazon-product-research-assistant/SKILL.md
```

Load it in a session:

```bash
hermes -s amazon-product-research-assistant
```

Or inside an active Hermes session:

```text
/skill amazon-product-research-assistant
```

## Install the `/product-research` bundle

### Default Hermes profile

```bash
mkdir -p ~/.hermes/skill-bundles
curl -fsSL https://raw.githubusercontent.com/flying864/hermes-ecommerce-skills/main/bundles/product-research.yaml \
  -o ~/.hermes/skill-bundles/product-research.yaml
```

### Named profile

Replace `PROFILE_NAME` with your Hermes profile name:

```bash
PROFILE_NAME=xiaosun
mkdir -p "$HOME/.hermes/profiles/$PROFILE_NAME/skill-bundles"
curl -fsSL https://raw.githubusercontent.com/flying864/hermes-ecommerce-skills/main/bundles/product-research.yaml \
  -o "$HOME/.hermes/profiles/$PROFILE_NAME/skill-bundles/product-research.yaml"
```

> Note: Hermes profiles are isolated. A bundle installed in one profile is not automatically visible in another profile.

## Recommended supporting skills

The bundle references these skills. Make sure they are available in the target profile:

- `amazon-product-research-assistant` — this repo
- `subagent-driven-development` — usually bundled with Hermes skills
- `youtube-content` — YouTube search/transcript workflows
- `html-artifact-generation` — publish-ready HTML report generation

If the supporting skills are missing, the bundle may load partially or produce a degraded report.

## Usage examples

### Product keyword research

```text
/product-research bowl covers
```

```text
/product-research garlic press, target amazon.com, focus on competition and profit
```

```text
/product-research 宠物除毛刷，目标美国站，重点看差评痛点、利润和合规风险
```

### ASIN / product URL deep dive

```text
/product-research https://www.amazon.com/dp/B0XXXXXXX 深度分析这个 ASIN 是否值得做
```

```text
/product-research B0XXXXXXX, compare against top 5 competitors and output HTML report
```

## Expected output

By default, the workflow should produce:

- A short chat summary:
  - recommendation level
  - score out of 100
  - one-line conclusion
  - next-step suggestion
  - HTML / ZIP attachment path
- A full HTML report containing:
  - executive conclusion
  - Amazon competition
  - Google Trends / trend notes
  - review insights
  - competitor analysis
  - YouTube / TikTok content opportunities
  - profit and FBA assumptions
  - compliance / IP risks
  - differentiation ideas
  - validation checklist

## Data-source rules

The skill is designed to use:

1. Public web data
2. User-provided exports, CSVs, screenshots, ASIN lists, or API responses
3. Third-party APIs when the user explicitly provides access and documentation

It should **not**:

- bypass platform anti-scraping controls
- bypass login walls or paywalls
- fabricate sales volume, search volume, CPC, revenue, or conversion rates
- present estimates as facts

Any sales volume, profit, CPC, FBA fee, and demand estimates must be labeled as **estimates** unless backed by a specific API or user-provided data export.

## Development / contribution workflow

The easiest way to improve this repo is through GitHub Issues and Pull Requests.

### Bug reports

Please open an issue when:

- the skill fails to load
- `/product-research` does not load the expected skills
- HTML report generation fails
- the report is too verbose, too shallow, or missing required sections
- data is mislabeled as factual when it should be marked as an estimate
- Amazon / Google Trends / YouTube / TikTok workflow assumptions become outdated

Please include:

```text
Hermes version:
Platform: CLI / Telegram / Discord / other
Profile name if relevant:
Input keyword / ASIN:
Expected behavior:
Actual behavior:
Error logs or screenshots if available:
Generated report file if safe to share:
```

### Pull requests

PRs are welcome for:

- better scoring frameworks
- improved multi-agent task prompts
- marketplace-specific guidance, e.g. Amazon US / UK / DE / JP
- better Google Trends fallback logic
- improved HTML report layout
- better review/pain-point extraction
- compliance and IP checklist improvements
- supplier validation workflows
- clearer install docs

Please avoid committing:

- API keys or tokens
- `.env`, `config.yaml`, auth files
- generated `.html`, `.zip`, screenshots, reports, or browser caches
- personal Telegram/chat IDs or server paths
- private customer/product data

## Maintainer notes

When updating the skill from a local Hermes profile, copy the whole skill directory, not only `SKILL.md`:

```bash
cp -r /path/to/profile/skills/ecommerce/amazon-product-research-assistant \
  ecommerce/amazon-product-research-assistant
```

When updating the bundle:

```bash
cp /path/to/profile/skill-bundles/product-research.yaml bundles/product-research.yaml
```

Then verify:

```bash
python3 - <<'PY'
from pathlib import Path
for p in [
    Path('ecommerce/amazon-product-research-assistant/SKILL.md'),
    Path('bundles/product-research.yaml'),
]:
    assert p.exists(), p
    text = p.read_text(encoding='utf-8')
    assert text.strip(), p
    print('ok', p, len(text), 'bytes')
PY
```

## License

MIT
