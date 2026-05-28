---
name: amazon-product-research-assistant
description: "Use when the user provides an Amazon product keyword and wants multi-agent product selection research: Amazon competition heat, Google Trends, third-party API enrichment, reviews, competitors, YouTube/TikTok content and comments, and actionable ecommerce opportunity scoring."
version: 1.0.0
author: Hermes Ecommerce Skills Community
license: MIT
metadata:
  hermes:
    tags: [amazon, ecommerce, product-research, selection, market-research, multi-agent, youtube, tiktok]
    related_skills: [subagent-driven-development, youtube-content, html-artifact-generation]
---

# 亚马逊选品助手

## Overview

当用户给出一个产品关键词时，本 Skill 用于组织多个 agent 并行完成亚马逊选品调研，输出可执行的选品判断：市场需求、竞争热度、趋势变化、竞品格局、评论痛点、内容平台热度、风险点、差异化机会、利润假设和下一步验证动作。

核心原则：**不要只看销量或搜索量，要同时看需求、竞争、利润、差评痛点、内容热度、供应链可行性和合规风险。**

支持文件：

- `references/html-report-template-notes.md` — 用户要求 HTML 报告/短消息交付时的报告结构、趋势图/产品图要求、消息来源写法和 Telegram zip fallback。
- `references/asset-collection-notes.md` — Amazon SERP 产品图抓取、高清图 URL 转换、pytrends 趋势图生成、zipfile 打包 fallback 的可复用细节。
- `references/asin-deep-dive-notes.md` — 用户给出明确 ASIN 并准备做该产品时的专项调研流程、竞品/评论/供应链/合规/利润/首批测试判断。
- `references/product-research-bundle-notes.md` — 将本 Skill 封装成 `/product-research` bundle 的推荐组合、instruction 模板、调用示例和多 agent 执行注意事项。

## When to Use

使用场景：

- 用户提供一个或多个产品关键词，要求判断是否适合做 Amazon / 跨境电商选品。
- 用户要求分析 Amazon 竞争热度、Google Trends、竞品、评论、YouTube / TikTok 内容。
- 用户提供第三方选品插件 / API，希望接入 API 查询更详细数据。
- 用户希望多个 agent 同步跑不同分析任务。

不要使用：

- 只需要写 Amazon listing 文案时，除非同时需要选品分析。
- 用户明确只要广告投放策略，且不需要产品调研。
- 涉及绕过平台反爬、登录风控、付费墙或违反网站条款的数据抓取请求。此时优先使用官方 API、第三方合规 API、公开网页、手动导出的 CSV 或用户提供的数据。

## Inputs to Collect

如果用户只给关键词，也可以直接开始；缺失信息用默认假设并在报告里标注。

优先收集：

- **产品关键词**：英文关键词优先；如用户给中文，要翻译出 3-8 个英文搜索词。
- **目标站点**：默认 `amazon.com`，可选 `amazon.co.uk`、`amazon.de`、`amazon.ca` 等。
- **目标市场**：美国 / 欧洲 / 日本等。
- **预算范围**：默认小团队轻资产模式。
- **售价区间**：默认优先 $15-$60。
- **产品类型偏好**：轻小件、非电子、低售后、低认证风险优先。
- **第三方 API 信息**：API 名称、endpoint、token、调用示例、字段说明。

## Multi-Agent Orchestration

### 推荐并行结构

Hermes 当前并发通常有限，使用 `delegate_task` 的 batch 模式，每批最多 3 个 agent。先跑基础市场数据，再跑深度内容与机会分析。

执行纪律：

- 如果某个并行 agent 因 provider/API 临时错误失败，不要让整次调研停住；保留已完成 lane 的结果，并用直接 `web_search` / 浏览器 / 单独重跑失败 lane 补齐缺口。
- 最终报告必须标注哪些数据来自公开网页观察、哪些是估算、哪些 lane 因工具/API 不可用而存在缺口。
- 用户说“测试运行一下”时，仍按完整选品流程执行，并默认交付美观 HTML 报告附件，而不是只在聊天里给长文本摘要。

### Batch 1：市场与趋势

并行派发：

1. **Amazon Competition Agent**
   - 搜索 Amazon 关键词结果。
   - 记录前 20-50 个自然结果的标题、品牌、价格、评分、评论数、BSR（如页面公开显示）、Coupon、变体数量、是否 Sponsored。
   - 判断竞争热度：头部评论垄断、价格带、品牌集中度、Listing 质量、广告密度。

2. **Google Trends Agent**
   - 查看关键词 5 年、12 个月、90 天趋势。
   - 对比同义词、替代词、细分关键词。
   - 识别季节性、增长/衰退、地区热度。

3. **Third-Party API Agent**
   - 如果用户提供 API / 插件，按文档调用。
   - 常见数据：搜索量、销量估算、销售额、关键词难度、CPC、BSR 历史、价格历史、库存变化、竞品 ASIN 列表。
   - 如果没有 API，说明缺口，不编造数据。

### Batch 2：评论与竞品

并行派发：

1. **Review Intelligence Agent**
   - 分析 Amazon 产品优评 / 差评。
   - 重点看 1-3 星评论中的反复痛点：质量、尺寸、气味、安装、耐用性、包装、说明书、售后、配件缺失。
   - 提炼可改进点和差异化卖点。

2. **Competitor Strategy Agent**
   - 选择 5-10 个主要竞品。
   - 对比标题、图片、A+ 页面、卖点、价格、套装、变体、品牌定位、评论护城河。
   - 判断是否存在“弱竞品”：评论多但差评集中、图片差、文案差、配件缺失、定价混乱。

3. **Profit and Operations Agent**
   - 估算成本结构：出厂价、头程、FBA fee、Referral fee、广告 ACOS、退货损耗。
   - 判断体积重量、易碎、液体、电池、食品接触、儿童用品、医疗宣称、专利等风险。
   - 输出利润敏感性：售价下降 10%、CPC 上升、退货率上升时是否还能做。

### Batch 3：内容平台需求验证

并行派发：

1. **YouTube Video Analysis Agent**
   - 必须搜索关键词及 pain point 关键词对应的 YouTube 视频。
   - 覆盖测评、开箱、教程、Top list、problem-solution、before/after、gift idea、DIY/使用场景等视频类型。
   - 分析视频标题、播放量、发布时间、频道类型、视频描述、评论情绪、常见问题、购买动机和可传播内容角度。
   - 优先使用 `youtube-content` skill 获取 transcript；没有字幕/评论数据时明确标注缺口，不要假装已经分析。

2. **TikTok Agent**
   - 搜索关键词、hashtag、产品使用场景。
   - 记录热视频主题、互动量、评论痛点、用户表达的购买意图。
   - 遵守平台条款；优先用公开页面、官方/合规 API、第三方数据源或用户导出的链接/CSV。

3. **Opportunity Synthesis Agent**
   - 汇总所有 agent 的结果。
   - 给出产品机会评分、是否建议进入、建议切入角度、验证清单。

## Data Sources and Methods

### Amazon

可用方式按优先级：

1. 用户提供第三方工具/API 数据，例如 Helium 10、Jungle Scout、Keepa、DataDive、SellerSprite、Rainforest API、Bright Data、Oxylabs 等。
2. Amazon Product Advertising API（如果用户有资质）。
3. 公开搜索结果和公开商品页的人工式浏览分析。
4. 用户导出的 CSV / 截图 / ASIN 列表。

重点字段：

- 搜索结果数量和广告密度。
- Top listings 的价格、评分、评论数、品牌数。
- Review moat：前 10 名平均评论数、中位评论数、低评论新品是否能排上来。
- Listing quality：主图、场景图、视频、A+、标题关键词覆盖。
- 价格带：低价血拼 / 中端可溢价 / 高端品牌化。
- 差评集中点：是否能通过产品改良解决。

### Google Trends

分析维度：

- 5 年趋势：长期增长还是短期爆款。
- 12 个月趋势：当前是否上升。
- 90 天趋势：近期热度变化。
- 地区分布：是否匹配目标站点。
- Related queries：寻找细分关键词和替代词。
- 多关键词对比：主词、长尾词、同义词、使用场景词。

### Third-Party API Integration

如果用户提供 API，先读取/询问以下信息：

- Base URL。
- Auth 方式：Bearer token / API key header / query key / basic auth。
- Endpoint：关键词查询、ASIN 查询、评论查询、销量估算、趋势查询。
- Rate limit。
- 示例响应字段。

调用规则：

- 不把 API key 写入 skill 或代码仓库。
- 优先从环境变量读取 token。
- 对返回字段做解释，不直接堆 JSON。
- 如果 API 返回销量/销售额估算，要标注“估算值，非 Amazon 官方数据”。

### YouTube

分析维度：

- 视频数量和近 6-12 个月新增速度。
- 爆款视频主题：测评、开箱、教程、问题解决、对比、DIY、礼物推荐。
- 评论里出现的真实需求、吐槽、购买疑虑。
- KOL/频道类型：专业测评、生活方式、垂直圈层、普通用户。
- 是否适合做短视频素材和 influencer outreach。

### TikTok

分析维度：

- hashtag 规模和近期热视频数量。
- 视频内容类型：before/after、problem-solution、unboxing、life hack、gift idea。
- 评论购买意图：where to buy、link please、need this、price、shipping。
- 产品是否具备“视觉冲击”和“3 秒理解价值”。
- 是否容易被达人演示。

## Scoring Framework

总分 100，默认权重：

- **Demand 需求强度（20）**：搜索趋势、内容热度、用户问题是否真实。
- **Competition 竞争可进入性（20）**：评论护城河、品牌垄断、广告密度、Listing 质量。
- **Differentiation 差异化空间（15）**：差评痛点是否可改良、套装/材质/设计/说明书/场景化机会。
- **Profit 利润空间（15）**：售价、FBA 成本、广告成本、退货率、毛利安全垫。
- **Operational Fit 运营难度（10）**：体积、易碎、变体、质检、售后复杂度。
- **Compliance Risk 合规风险（10）**：认证、专利、侵权、危险品、医疗/儿童/食品接触。
- **Content Virality 内容传播性（10）**：YouTube/TikTok 是否容易演示、是否有达人生态。

推荐判断：

- **80-100**：强机会，建议进入样品验证。
- **65-79**：可研究，需找到明确差异化或更细分关键词。
- **50-64**：谨慎，只适合低成本测试。
- **<50**：不建议进入，除非用户有供应链或品牌优势。

## Output Format

最终报告默认用中文。**用户已明确偏好：选品调研/产品分析报告默认输出为美观 HTML 文件附件，聊天里只发简短结论 + 附件，不要长篇纯文本。** 除非用户明确要求聊天内全文，否则不要把完整报告直接贴到聊天里。

### 聊天内简短版

只发送：

- 结论等级
- 总分
- 文件附件
- 1 句下一步建议

### HTML 文件版

**交叉 skill 要求：只要最终要生成 HTML/ZIP 报告，必须先加载并遵循 `html-artifact-generation` skill。** 不要只依赖本 skill 内的报告结构手写 HTML；先用本 skill 负责调研框架和数据组织，再用 `html-artifact-generation` 负责成品 HTML 的信息架构、视觉系统、单文件/资源策略和验证。用户如果指出“你有 HTML 生成 skill 吗/刚才用了吗”，应承认并立即按该 skill 规范重生成，而不是辩解。

HTML 报告应包含：

- 结论先行、评分、推荐/不推荐理由
- Amazon 竞争、趋势、评论、竞品、内容平台、利润、供应链、合规/IP、测试计划
- **默认必须包含视觉资产**：至少 4-6 张 Amazon 竞品/目标产品图片卡片，以及 Google Trends 近 1 年 + 近 5 年两张趋势图。除非图片/趋势数据确实无法获取，否则不要交付纯文字 HTML。
- 产品图片卡片必须包含：产品图、ASIN、价格、评分/评论、稳定 Amazon `/dp/{ASIN}` 链接。
- Google Trends 图必须嵌入报告：优先真实 pytrends/API 导出并绘图；API 失败时用浏览器复核并截图/提取数据；只有两者都不可用时才生成代理趋势图并明确标注。
- 卡片式布局，适合手机查看
- 明确标注“公开网页观察 / 估算 / 缺失需 API 复核”
- 视觉要求：要“美观些”，优先使用现代卡片式布局、清晰评分、颜色区分风险/机会、移动端适配；避免像纯文档或表格堆砌。
- 如果有产品图片/趋势图等本地资源，发送 zip；如果是纯内联 HTML，可直接发送 `.html`。
- **如果 HTML 使用本地产品图、趋势图或其他资源，必须 zip 打包**；如果是纯内联 CSS/HTML、无外部资源，可直接发送 `.html` 或 zip，优先选择平台更稳定的 zip。

### Telegram 发送注意

- 生成文件后先确认文件存在和大小，再发送 `MEDIA:/absolute/path/file.html`。
- 如果用户反馈没收到 `.html`，优先把 HTML 压缩成 `.zip` 再发送；部分聊天平台对 `.html` 附件可能处理不稳定。
- 不要反复发送长文本补偿，用户明确不想要长消息。

最终报告正文结构固定：

```markdown
## 关键词
- 主关键词：
- 相关关键词：
- 目标站点/市场：

## 结论先行
- 推荐等级：强烈推荐 / 可测试 / 谨慎 / 不建议
- 总分：xx/100
- 一句话判断：

## 核心数据摘要
- Amazon 竞争热度：
- Google Trends：
- 第三方 API 数据：
- YouTube 内容热度：
- TikTok 内容热度：

## Amazon 竞争分析
- 价格带：
- 评论护城河：
- 广告密度：
- 主要竞品：
- 弱点机会：

## 评论洞察
- 高频好评点：
- 高频差评点：
- 可改良方向：

## 竞品分析
- 头部竞品：
- 可避开的红海点：
- 可切入的细分定位：

## 内容平台分析
- YouTube：
- TikTok：
- 可制作的内容角度：

## 利润与风险
- 推荐售价：
- 成本/费用假设：
- 主要风险：
- 合规/专利检查建议：

## 差异化产品方案
1. 方案 A：
2. 方案 B：
3. 方案 C：

## 下一步验证清单
- [ ] 样品搜索与供应商询价
- [ ] 专利/商标初筛
- [ ] FBA fee 估算
- [ ] 小批量广告关键词测试
- [ ] Listing mockup 和主图测试
```

## Extra Suggestions / 优化方向

除了用户提出的项目，主动补充以下分析：

1. **关键词分层**
   - 主关键词通常很红海，要挖：场景词、人群词、问题词、材质词、尺寸词、套装词。
   - 例：`dog bed` 不如继续拆 `orthopedic dog bed for large dogs washable cover`。

2. **专利和商标初筛**
   - 在进入前检查 USPTO / Google Patents / Amazon 品牌名。
   - 特别警惕外观专利、功能专利、品牌词侵权。

3. **合规认证风险**
   - 儿童用品、食品接触、医疗健康、电池、电子、化妆品、宠物食品、承重安全类产品要提高风险权重。

4. **供应链可行性**
   - 看 1688 / Alibaba / Made-in-China 是否有成熟供应。
   - 判断 MOQ、定制难度、质检点、包装体积。

5. **广告成本预估**
   - 如果 CPC 高且客单价低，利润容易被广告吃掉。
   - 关注关键词是否被大品牌占满 Sponsored 位。

6. **退货和售后复杂度**
   - 尺码、颜色、适配性强的产品退货率可能高。
   - 安装复杂、说明书差的产品虽然有机会，但也会增加客服成本。

7. **变体策略**
   - 颜色/尺寸太多会压库存；新手优先 1-3 个核心 SKU。

8. **礼品属性**
   - 有 giftable 属性的产品更适合 TikTok / YouTube / 节日流量。

9. **订阅和耗材属性**
   - 如果有滤芯、替换件、耗材、配件复购，长期价值更高。

10. **差评反向创新**
    - 不是所有差评都值得改。优先改“高频、可工程解决、用户愿意付费”的痛点。

11. **小批量验证路径**
    - 先用 1-2 个差异化 SKU、小库存、低预算广告验证 CTR/CVR，再扩 SKU。

12. **退出标准**
    - 进入前定义失败条件：CPC 超阈值、CVR 低于预期、退货率过高、差评集中在不可解决问题。

## HTML Deliverable Mode

When the user asks for an HTML report or says not to send a long message:

- Generate a compact, self-contained `.html` report file instead of pasting the full analysis into chat.
- Keep the chat reply short: one sentence plus the file attachment/path.
- The HTML should include executive conclusion, score, recommendation, product方案, validation plan, risks, and next steps.
- Prefer mobile-readable layout: cards, bullets, clear headings, no wide tables that break in Telegram.
- If Telegram delivery of `.html` fails, zip the HTML and send the `.zip` as fallback; do not repeatedly paste the same `MEDIA:` text.
- Keep a reusable report structure in `references/html-report-template-notes.md`.

## Publishing / Sharing This Skill

当用户要求把本 Skill 给其他 agent 使用、迁移或公开同步到 GitHub：

- 迁移最小单元是整个目录：`amazon-product-research-assistant/SKILL.md` + `references/`，不要只复制 `SKILL.md`。
- 公开仓库推荐结构：

```text
hermes-ecommerce-skills/
└── ecommerce/
    └── amazon-product-research-assistant/
        ├── SKILL.md
        └── references/
            ├── asin-deep-dive-notes.md
            └── html-report-template-notes.md
```

- 公开前清理个人化内容和运行产物：不要提交 `.html`、`.zip`、`.json`、`report_assets/`、`browser_screenshots/`、`.env`、`config.yaml`、API key、Telegram/chat id、个人服务器路径等。
- README 应提供 raw 安装命令：

```bash
hermes skills install https://raw.githubusercontent.com/<owner>/<repo>/main/ecommerce/amazon-product-research-assistant/SKILL.md
```

- 如果通过 GitHub 发布，完成后用 raw URL 拉取前几行验证 frontmatter 可访问，并确认仓库 visibility 是 PUBLIC。

## Common Pitfalls

1. **只看搜索量，不看竞争护城河。** 高搜索量但前 10 名评论数巨大，通常不适合新手硬打。
2. **把第三方销量估算当事实。** Helium 10 / Jungle Scout / Keepa 等都是估算，要交叉验证。
3. **忽略差评的真实性。** 少量差评不代表机会，必须看是否高频、近期、可解决。
4. **忽略平台内容热度。** Amazon 有需求但 TikTok/YouTube 没有演示价值，冷启动会更难。
5. **低估广告成本。** 客单价低、CPC 高、转化慢的产品很容易亏。
6. **忽略专利/认证。** 看起来很好卖的产品可能因为专利、医疗宣称、儿童安全等不能碰。
7. **让多个 agent 重复查同一件事。** 每个 agent 要有清晰边界，最后由 Synthesis Agent 汇总。
8. **输出数据没有来源。** 报告里要区分：工具数据、公开网页观察、估算、假设。

## Verification Checklist

开始前：

- [ ] 明确关键词和目标 Amazon 站点。
- [ ] 如果有第三方 API，确认 endpoint、auth、rate limit。
- [ ] 给每个 agent 分配不重叠任务。

执行中：

- [ ] Amazon 前排竞品至少覆盖 10 个，最好 20 个。
- [ ] Google Trends 至少看 5 年、12 个月、90 天。
- [ ] 评论分析覆盖好评和差评，重点是 1-3 星。
- [ ] YouTube/TikTok 不只看播放量，也看评论里的购买意图和痛点。
- [ ] 利润分析明确标注假设。

最终报告：

- [ ] 如果输出 HTML/ZIP 报告，已加载 `html-artifact-generation` 并按其验证清单执行。
- [ ] 有明确推荐等级和总分。
- [ ] 有“不建议做”的可能性，不强行给正面结论。
- [ ] 有 3 个以上差异化方案。
- [ ] 有风险清单和下一步验证清单。
- [ ] 对所有无法获取的数据标注“缺失/需 API/需用户提供”。

## One-Shot Prompt Template

当用户给出关键词后，可按这个模板调度：

```text
用户关键词：{keyword}
目标站点：{amazon_marketplace 或 amazon.com}
目标市场：{market 或 美国}
第三方 API：{api_info 或 无}

请使用多个 agent 分批并行完成：
1. Amazon 竞争热度
2. Google Trends 趋势
3. 第三方 API 数据
4. 评论洞察
5. 竞品分析
6. YouTube 内容与评论
7. TikTok 内容与评论
8. 利润、合规、供应链风险

最后输出中文报告，包含推荐等级、100 分评分、是否建议进入、差异化方案和下一步验证清单。
```
