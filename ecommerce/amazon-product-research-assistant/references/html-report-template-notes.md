# HTML 选品报告交付细节

用于 Amazon/电商选品报告中，用户要求“输出为 HTML”“不要发长消息”“发文件给我”时。

## 报告内容要求

- 用户已明确偏好：选品调研/产品分析报告默认输出为**美观 HTML 文件附件**，聊天里只发简短结论和附件，不要长篇纯文本。
- HTML 内要比聊天摘要更完整：结论、评分、Amazon 竞争、Google Trends、评论洞察、竞品格局、YouTube/TikTok、供应链、IP/合规、利润模型、30-45 天测试计划。
- 视觉设计要“美观些”：优先现代卡片式布局、深浅主题均可、清晰评分区、颜色区分机会/风险/警告、移动端适配；避免纯 Markdown 风格和密集表格堆砌。
- 底部必须加入“消息来源 / 数据来源”，明确区分：
  - Amazon 公开搜索结果观察
  - Google Trends / 第三方 API / 公开网页搜索
  - 多 agent 分析模块
  - 估算与假设，不是 Amazon 官方销量
- 如果报告引用产品图片，应标注“图片来自公开搜索结果，仅用于竞品形态参考，不可复制外观”。
- 如果加入趋势图，优先获取真实 Google Trends 数据；若 Google Trends/pytrends 返回 429 或无法访问，可生成“代理趋势示意图”，但必须在图旁和来源处明确标注：不是官方趋势导出，正式决策需用 DataForSEO 或手动 Google Trends 复核。

## 资产打包规则

- 如果 HTML 是纯文本/CSS 内联文件，可以直接发送 `.html`。
- **选品报告默认不应是纯文本 HTML**：除非明确不可获取，必须包含竞品/目标产品图片和 Google Trends 图表。用户已纠正过“没有图片”的报告不合格。
- 如果 HTML 引用本地图片、趋势图、CSS、JS 等相对路径资源，不要只发送单个 `.html`，否则用户打开会缺图。
- 正确做法：把 HTML 和资源目录一起打包成 zip，例如：
  - `amazon_bowl_covers_report.html`
  - `report_assets/*.png`
  - `report_assets/*.jpg`
  - 打包为 `amazon_bowl_covers_report_with_assets.zip`
- 聊天回复保持短：一句说明 + `MEDIA:/absolute/path/report_with_assets.zip`。

## Google Trends 图表规则

- 需要两张图时默认：近 1 年、近 5 年。
- 关键词建议同时对比：大盘词（如 `sourdough`）+ 精准转化词（如 `bread proofing`、`dough cover`、`reusable bowl covers`）。
- 图表旁必须说明数据来源状态：真实导出 / API 失败后的代理示意。
- 不要把代理图说成官方 Google Trends 结果。
- **遇到 pytrends 429 时不要直接放弃**：先降低请求频率、避免多关键词同批 compare、改成单关键词逐个请求，并在每次请求之间等待 8-20 秒。
- **如果 pytrends 仍失败，必须用浏览器打开 Google Trends 页面复核**：例如 `https://trends.google.com/trends/explore?date=today%2012-m&geo=US&q=bread%20proofing` 和 `date=today%205-y`。浏览器页面常常能正常加载，即使 pytrends API 返回 429。
- 浏览器可用时，优先从页面可访问表格/截图提取真实趋势数据或截图，不要生成代理趋势图。只有浏览器也无法打开/数据不足时，才允许代理示意图。

## 产品图片规则

- 优先使用公开搜索结果中可见的 Amazon 产品图或品牌公开图。
- 下载到 `report_assets/`，HTML 用相对路径引用。
- 图片说明要写“竞品形态参考”，避免用户误以为可复制。
- 产品图片卡片应包含：产品形态、价格参考、定位/风险一句话。
- **竞品图片下方必须放可点击链接**：优先使用稳定的 `https://www.amazon.com/dp/{ASIN}` 形式，避免使用带广告追踪参数的 `sspa/click` 长链接。
- 链接旁建议显示 ASIN、价格、评分、评论数；打开方式用 `target="_blank" rel="noopener noreferrer"`。
- 如果报告包含多个竞品卡片，发送前验证 HTML 中 Amazon `/dp/` 链接数量与竞品卡片数量基本一致。

## 数据来源 / 消息来源规则

- 底部来源不要只写笼统“Amazon/Google/公开网页”。要拆成详细来源：Amazon 搜索页、竞品图片与链接、Google Trends、评论洞察、供应链/成本假设、YouTube/TikTok、第三方工具缺口、多 Agent 模块、数据观察时间。
- Amazon 来源应列明关键词、站点、采集字段（标题、ASIN、链接、主图、价格、评分、评论数、广告位/竞品形态）和重点样本 ASIN。
- Google Trends 来源要说明获取路径：pytrends/API 是否成功、是否触发 429、是否用浏览器手动复核、图表是官方导出还是代理示意。
- 第三方工具没有接入时必须明确写“未接入 Helium 10 / Jungle Scout / Keepa / SellerSprite / DataForSEO / Rainforest API 等付费接口”，避免用户误以为有真实销量/搜索量。
- 所有销量、利润、FBA、广告、成本、CPC 数据都要标注为公开信息 + 假设估算，正式下单前需要工具或手动复核。

## Telegram 交付规则

- 发送前确认文件存在和大小。
- `.html` 可直接发送；但带本地资源时发 `.zip` 更可靠。
- 如果用户反馈没收到，不要反复贴长文本；改发 zip 或检查 MEDIA 扩展识别。
