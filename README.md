# Hermes Ecommerce Skills

Reusable ecommerce research skills for [Hermes Agent](https://github.com/NousResearch/hermes-agent).

## Included skills

### `amazon-product-research-assistant`

A multi-agent Amazon product research skill for product selection and ecommerce opportunity analysis.

It helps analyze:

- Amazon competition heat and competitor links
- Google Trends 1-year / 5-year trend checks
- Review pain points and product improvement opportunities
- YouTube / TikTok content validation
- Supply chain, profit, compliance, and IP risks
- HTML report delivery with product images and data sources

## Install

Install directly from GitHub:

```bash
hermes skills install https://raw.githubusercontent.com/flying864/hermes-ecommerce-skills/main/ecommerce/amazon-product-research-assistant/SKILL.md
```

Load in a session:

```bash
hermes -s amazon-product-research-assistant
```

Or inside an active Hermes session:

```text
/skill amazon-product-research-assistant
```

## Example prompt

```text
Research this Amazon product keyword: Baguette baking tray.
Output a beautiful HTML report with product images, Google Trends 1-year and 5-year charts, competitor links, detailed data sources, scoring, and a next-step validation plan.
```

## Notes

- The skill is designed to use public web data and user-provided third-party APIs when available.
- It should not bypass platform anti-scraping controls, login walls, or paywalls.
- Any sales volume, profit, CPC, and FBA estimates must be labeled as estimates unless backed by a specific API or user-provided data export.

## Repository structure

```text
hermes-ecommerce-skills/
└── ecommerce/
    └── amazon-product-research-assistant/
        ├── SKILL.md
        └── references/
            ├── asin-deep-dive-notes.md
            └── html-report-template-notes.md
```

## License

MIT
