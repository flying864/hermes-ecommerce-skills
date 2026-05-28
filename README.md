# Hermes Ecommerce Skills

这是给 [Hermes Agent](https://github.com/NousResearch/hermes-agent) 使用的跨境电商/亚马逊选品 Skill 和 Bundle 仓库。

当前重点是 **Amazon 产品调研 / 选品判断**：竞争热度、Google Trends、评论痛点、竞品策略、YouTube/TikTok 内容验证、利润假设、合规/IP 风险，以及 HTML 报告交付。

## 这个项目解决什么问题？

很多人让 AI 做选品时，容易得到一篇“看起来很完整、但数据来源不清楚”的长报告。本项目的目标是把选品调研拆成固定流程：

1. 先看 Amazon 竞争和评论护城河
2. 再看趋势、内容平台和用户真实痛点
3. 再估算利润、FBA、广告和合规风险
4. 最后输出明确的推荐等级、100 分评分、差异化方案和下一步验证清单
5. 默认生成 HTML 报告，聊天里只给简短结论

核心原则：**不编造销量，不把估算当事实，不绕过平台限制。**

## 仓库内容

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

## 先理解：Skill 和 Bundle 有什么区别？

### Skill：能力本体

`amazon-product-research-assistant` 是核心 Skill，里面写了完整选品流程：

- Amazon 竞争分析
- Google Trends 分析
- 第三方 API / CSV 数据接入规则
- 评论痛点分析
- 竞品策略分析
- YouTube / TikTok 内容需求分析
- 利润、FBA、合规、IP 风险判断
- HTML 报告结构

你可以单独加载这个 Skill 使用。

### Bundle：快捷命令入口

`/product-research` 是 Bundle。它不是新的能力，而是一个**快捷入口**，会一次性加载多个 Skill，并附加固定 instruction。

这个 Bundle 会加载：

```yaml
skills:
  - amazon-product-research-assistant
  - subagent-driven-development
  - youtube-content
  - html-artifact-generation
```

也就是说，你不用每次手动说：

```text
请加载亚马逊选品 skill、YouTube 分析 skill、HTML 报告 skill，并用多 agent 分工执行……
```

你只需要发：

```text
/product-research bowl covers
```

Hermes 就会按选品流程开始执行。

## `/product-research` 正确使用方式

### 基本格式

```text
/product-research 产品关键词或ASIN或Amazon链接 + 你的要求
```

例如：

```text
/product-research bowl covers
```

```text
/product-research garlic press，目标美国站，重点看竞争和利润
```

```text
/product-research 宠物除毛刷，目标美国站，重点看差评痛点、利润和合规风险
```

```text
/product-research https://www.amazon.com/dp/B0XXXXXXX 深度分析这个 ASIN 是否值得做
```

### 推荐输入格式

为了让报告更准确，建议尽量包含这 4 类信息：

```text
/product-research [产品关键词/ASIN/链接]，[目标站点]，[预算/售价区间]，[重点关注点]
```

示例：

```text
/product-research electric lunch box，目标 amazon.com，售价 25-45 美元，重点看合规风险和广告成本
```

```text
/product-research silicone stretch lids，目标美国站，新手小团队，重点看是否同质化严重
```

```text
/product-research B0XXXXXXX，比较前 10 个竞品，判断是否值得做差异化版本
```

### 可以输入中文吗？

可以。中文品类会被 Hermes 转成多个英文关键词去调研。

例如：

```text
/product-research 宠物自动喂食器，目标美国站
```

Hermes 应该扩展出类似关键词：

```text
automatic pet feeder
cat automatic feeder
dog food dispenser
timed pet feeder
```

### 可以输入 ASIN 吗？

可以。适合做单品深度分析：

```text
/product-research B0XXXXXXX 深度分析这个 ASIN 是否值得跟进
```

建议同时说明你的目标：

```text
/product-research B0XXXXXXX，判断我能不能做改良版，重点看差评痛点、专利风险和利润空间
```

### 可以输入 Amazon 链接吗？

可以：

```text
/product-research https://www.amazon.com/dp/B0XXXXXXX
```

或者：

```text
/product-research https://www.amazon.com/example-product/dp/B0XXXXXXX 重点看竞品和评论痛点
```

### 可以指定国家站点吗？

可以。默认是 `amazon.com` 美国站。如果你要其他站点，请明确写出来：

```text
/product-research lunch box，目标 amazon.co.uk，英国市场
```

```text
/product-research coffee scale，目标 amazon.de，德国市场
```

```text
/product-research rice storage container，目标 amazon.co.jp，日本市场
```

### 可以提供第三方数据吗？

可以，而且更好。你可以提供：

- Helium 10 导出的 CSV
- Jungle Scout 数据
- Keepa 截图或导出
- SellerSprite 数据
- DataForSEO / Rainforest API 返回结果
- 自己整理的 ASIN 列表
- 供应商报价
- FBA 费用截图

使用示例：

```text
/product-research garlic press，结合我上传的 CSV，重点判断是否还能进入
```

注意：没有第三方数据时，Hermes 必须标注“第三方销量/搜索量数据缺失”，不能编造。

## Bundle 会怎样执行？

`/product-research` 会尽量使用多 agent 分工。典型流程如下：

### Batch 1：市场与趋势

- **Amazon Competition Agent**：看 Amazon 搜索结果、价格带、评分/评论数、评论护城河、广告密度、品牌集中度、Listing 质量
- **Google Trends Agent**：看 5 年、12 个月、90 天趋势、地区热度、相关查询和同义关键词
- **Third-Party/API Agent**：如果你提供 API/CSV/插件数据，就解析；没有就标注缺失

### Batch 2：评论、竞品、利润风险

- **Review Intelligence Agent**：分析好评卖点和 1-3 星差评痛点
- **Competitor Strategy Agent**：分析 5-10 个主要竞品、弱竞品、差异化空间、图片/标题/A+ 页面机会
- **Profit/Risk Agent**：估算售价、成本、FBA、Referral fee、广告 ACOS、退货率、供应链、合规/IP/认证风险

### Batch 3：内容平台与综合判断

- **YouTube Video Analysis Agent**：必须搜索 YouTube 相关视频（测评、开箱、教程、Top list、problem-solution、before/after、gift idea 等），分析标题、播放量、发布时间、频道类型、视频描述、评论痛点、购买动机和可传播内容角度；可用时必须使用 `youtube-content` 抓取 transcript，不可用时明确标注“字幕/评论数据缺失”。
- **TikTok/Social Agent**：分析短视频传播性、内容形式、评论购买意图；无法访问时标注缺口
- **Opportunity Synthesis Agent**：汇总所有结果，给出 100 分评分、推荐等级、进入/放弃理由和下一步验证计划

如果当前 Hermes 环境没有 `delegate_task` 多 agent 工具，或者某个子 agent 失败，应该继续用可用工具补齐，并在报告里明确标注缺口。

## 输出结果是什么样？

默认输出两部分：

### 1. 聊天里的简短结论

例如：

```text
结论：谨慎，可小批量测试细分款｜评分：55/100。
不建议直接做普通低价塑料/硅胶 bowl covers；如果要做，优先考虑 sourdough 发酵专用布艺盖、大尺寸碗盖套装、微波防溅两用盖。

MEDIA:/path/to/report.html
```

### 2. HTML 报告附件

HTML 报告应包含：

- 结论先行
- 100 分评分
- Amazon 竞争分析
- Google Trends / 趋势说明
- 评论洞察
- 竞品分析
- YouTube / TikTok 内容机会
- 利润与 FBA 假设
- 合规 / IP 风险
- 差异化产品方案
- 下一步验证清单
- 数据来源与缺失数据说明

## 安装 Skill

安装核心 Skill：

```bash
hermes skills install https://raw.githubusercontent.com/flying864/hermes-ecommerce-skills/main/ecommerce/amazon-product-research-assistant/SKILL.md
```

加载 Skill：

```bash
hermes -s amazon-product-research-assistant
```

或者在 Hermes 会话里输入：

```text
/skill amazon-product-research-assistant
```

## 安装 `/product-research` Bundle

### 默认 Hermes profile

```bash
mkdir -p ~/.hermes/skill-bundles
curl -fsSL https://raw.githubusercontent.com/flying864/hermes-ecommerce-skills/main/bundles/product-research.yaml \
  -o ~/.hermes/skill-bundles/product-research.yaml
```

### 指定 Hermes profile

把 `PROFILE_NAME` 改成你的 profile 名称：

```bash
PROFILE_NAME=xiaosun
mkdir -p "$HOME/.hermes/profiles/$PROFILE_NAME/skill-bundles"
curl -fsSL https://raw.githubusercontent.com/flying864/hermes-ecommerce-skills/main/bundles/product-research.yaml \
  -o "$HOME/.hermes/profiles/$PROFILE_NAME/skill-bundles/product-research.yaml"
```

注意：Hermes 的 profile 是隔离的。你装到 `xiaosun`，其他 profile 不会自动看到。

## 安装后如何确认成功？

### 1. 确认文件存在

默认 profile：

```bash
ls ~/.hermes/skill-bundles/product-research.yaml
```

指定 profile：

```bash
PROFILE_NAME=xiaosun
ls "$HOME/.hermes/profiles/$PROFILE_NAME/skill-bundles/product-research.yaml"
```

### 2. 在 Hermes 里直接使用

CLI 或 Telegram 都可以：

```text
/product-research bowl covers
```

如果成功，Hermes 应该显示或内部加载类似信息：

```text
Bundle: product-research
Skills loaded: amazon-product-research-assistant, subagent-driven-development, youtube-content, html-artifact-generation
```

### 3. Telegram 下划线兼容

如果你的平台对 `-` 不方便，也可以试：

```text
/product_research bowl covers
```

是否支持取决于你的 Hermes gateway 版本；新版本通常会把 `_` 转成 `-`。

## 常见错误

### 错误 1：只安装了 Skill，没有安装 Bundle

如果你只执行了：

```bash
hermes skills install .../SKILL.md
```

那么你有了 `amazon-product-research-assistant`，但不一定有 `/product-research` 命令。

要使用 `/product-research`，还需要安装：

```text
bundles/product-research.yaml
```

### 错误 2：Bundle 安装到了错误 profile

比如你的 agent 运行在 `xiaosun` profile，但你把 bundle 放到了默认 profile：

```text
~/.hermes/skill-bundles/product-research.yaml
```

那 `xiaosun` 可能看不到。

应该放到：

```text
$HOME/.hermes/profiles/xiaosun/skill-bundles/product-research.yaml
```

### 错误 3：缺少辅助 Skill

Bundle 需要这些 Skill：

- `amazon-product-research-assistant`
- `subagent-driven-development`
- `youtube-content`
- `html-artifact-generation`

如果缺少，报告可能退化：

- 没有多 agent 分工
- 没有 YouTube transcript
- 没有美观 HTML 报告
- 只输出普通文本

### 错误 4：期待真实销量，但没有提供第三方数据

Hermes 不能凭空知道真实销量。没有 Helium 10、Jungle Scout、Keepa 等数据时，报告只能写：

```text
第三方销量/搜索量数据缺失，需 API 或手动导出复核。
```

这是故意设计的，避免误导。

## 数据来源规则

这个项目允许使用：

1. 公开网页数据
2. 用户提供的 CSV、截图、ASIN 列表、API 响应
3. 用户明确授权的第三方 API

不允许：

- 绕过平台反爬
- 绕过登录墙或付费墙
- 编造销量、搜索量、CPC、销售额、转化率
- 把估算值写成事实

所有销量、利润、CPC、FBA 费用和需求判断都必须标注为 **估算**，除非有明确 API 或用户提供的数据支持。

## 贡献和反馈

欢迎通过 GitHub Issues 和 Pull Requests 改进这个项目。

### 报告 bug 时请提供

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

适合提交 issue 的情况：

- skill 无法加载
- `/product-research` 没有加载预期 Skill
- HTML 报告生成失败
- 报告太浅、太长、缺少关键章节
- 把估算数据写成了事实
- Amazon / Google Trends / YouTube / TikTok 流程过时

### 欢迎 PR 改进

适合提交 PR 的方向：

- 更好的评分模型
- 更好的多 agent prompt
- 不同 Amazon 站点：US / UK / DE / JP
- 更好的 Google Trends fallback
- 更好的 HTML 报告布局
- 更好的评论痛点提取
- 更完整的合规/IP 检查清单
- 供应商验证流程
- 更清楚的安装文档

请不要提交：

- API key、token、密码
- `.env`、`config.yaml`、认证文件
- 生成的 `.html`、`.zip`、截图、报告、浏览器缓存
- 私人 Telegram/chat id 或服务器路径
- 私人客户数据或产品数据

## 维护者说明

从本地 Hermes profile 更新 Skill 时，要复制整个目录，不要只复制 `SKILL.md`：

```bash
cp -r /path/to/profile/skills/ecommerce/amazon-product-research-assistant \
  ecommerce/amazon-product-research-assistant
```

更新 Bundle：

```bash
cp /path/to/profile/skill-bundles/product-research.yaml bundles/product-research.yaml
```

提交前验证：

```bash
python3 - <<'PY'
from pathlib import Path
import yaml

for p in [
    Path('ecommerce/amazon-product-research-assistant/SKILL.md'),
    Path('bundles/product-research.yaml'),
]:
    assert p.exists(), p
    text = p.read_text(encoding='utf-8')
    assert text.strip(), p
    print('ok', p, len(text), 'bytes')

bundle = yaml.safe_load(Path('bundles/product-research.yaml').read_text(encoding='utf-8'))
assert bundle['name'] == 'product-research'
assert 'amazon-product-research-assistant' in bundle['skills']
print('bundle yaml ok')
PY
```

## License

MIT
