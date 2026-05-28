# Amazon Product Research Asset Collection Notes

Use these notes when generating HTML reports that must include Amazon product images and Google Trends charts.

## Amazon SERP product/image extraction

When Amazon search pages are accessible in the browser, use `browser_console` to extract product cards from `[data-asin]` nodes instead of manually copying each listing.

```js
Array.from(document.querySelectorAll('[data-asin]'))
  .filter(x => x.dataset.asin)
  .slice(0, 30)
  .map(el => {
    const asin = el.dataset.asin;
    const title = el.querySelector('h2 span')?.innerText?.trim() || '';
    const img = el.querySelector('img.s-image')?.src || '';
    const price = el.querySelector('.a-price .a-offscreen')?.innerText || '';
    const rating = el.querySelector('.a-icon-alt')?.innerText || '';
    const reviews =
      el.querySelector('[aria-label$="ratings"], [aria-label$="rating"]')?.getAttribute('aria-label') ||
      el.querySelector('a[href*="customerReviews"] span')?.innerText || '';
    const sponsored = !!el.innerText.match(/Sponsored/);
    return {asin, title, img, price, rating, reviews, sponsored, url: 'https://www.amazon.com/dp/' + asin};
  })
  .filter(x => x.title && x.img)
```

After extracting images, upgrade thumbnail URLs when possible:

- `._AC_UL320_.jpg` → `._AC_SL1000_.jpg`
- Keep the original URL as fallback if the high-res URL fails.

Download 4-8 representative competitor images into the report asset directory and store the structured product list as JSON beside the report. The HTML should link each card to stable `/dp/{ASIN}` URLs.

## Google Trends chart generation

Prefer real Trends charts via `pytrends` for 12-month and 5-year views. Compare the main keyword with close variants and scene keywords. For low-volume long tails, zeros can mean insufficient relative search volume, not no demand.

Example keyword set for fridge-lock style reports:

```python
keywords = [
    'fridge lock',
    'refrigerator lock',
    'freezer lock',
    'child proof fridge lock',
    'fridge door lock',
]
```

Generate both:

- `today 12-m` → `trend_1y_<keyword>.png`
- `today 5-y` → `trend_5y_<keyword>.png`

Always state in the report that Google Trends is normalized 0-100 relative interest, not absolute search volume.

## Packaging HTML reports with local assets

If the HTML references local images/charts, deliver a zip containing:

- report HTML
- asset directory
- structured source JSON when useful

If the system `zip` command is unavailable, use Python stdlib `zipfile` rather than stopping:

```python
from pathlib import Path
import zipfile

base = Path('/absolute/report/workdir')
zip_path = base / 'report_with_assets.zip'
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as z:
    z.write(base / 'report.html', 'report.html')
    for p in (base / 'report_assets').iterdir():
        if p.is_file():
            z.write(p, 'report_assets/' + p.name)
```

Verify before delivery: zip exists, non-zero size, contains the HTML and all image/chart assets.