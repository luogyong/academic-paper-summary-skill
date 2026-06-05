---
name: academic-paper-summary
description: >-
  使用FOCUS方法对学术论文进行严谨、细节保留的总结。当用户说"总结论文"、"论文总结"、
  "/summarize-paper"、"学术论文分析"、"提取论文核心内容"、"详细论文摘要"时触发。
  支持PDF/Word/图片（通过MinerU提取）、中文详细分析、Markdown输出、直接导入Obsidian、
  批量文件夹处理（一次性总结整个文件夹的所有论文）。
  特别适合需要完整捕捉论文细节、用于文献综述、研究复审的研究人员。
version: 0.1.0
author: Research Workflow Skills
license: MIT
tags: [academic-research, paper-analysis, focus-method, obsidian, chinese-support, batch-processing]
---

# 学术论文总结 Skill

## 核心功能

这个 Skill 实现了**细节保留型学术论文摘要工作流**，融合以下特性：

| 功能                 | 说明                                                                      |
| -------------------- | ------------------------------------------------------------------------- |
| **FOCUS 两阶段流程** | 逐段提取（含细节/引文/公式） → 结构化清理输出                                 |
| **MinerU 文档提取**  | 自动从 PDF/Word/图片提取高保真全文 Markdown                               |
| **LaTeX 公式保留**   | 保留原始 LaTeX 数学公式（`$...$` 和 `$$...$$`），非自然语言替代            |
| **中文优化**         | 所有指令、示例、输出均中文化，支持中文语境理解                            |
| **Obsidian Wiki 化** | 自动生成 wiki-link 格式（`[[双方括号]]`）、frontmatter metadata、标签系统 |
| **自动笔记导出**     | 结果直接导出为`.md` 文件，可一键导入 Obsidian vault                       |
| **多格式支持**       | PDF、Word、图片、网页、纯文本                                             |
| **批量文件夹处理**   | 一次性扫描并总结整个文件夹内的所有论文，自动生成批量索引                  |

---

## 依赖项与 Fallback

### MinerU（可选）
- **作用**：从 PDF/Word/图片提取高保真全文 Markdown
- **检测方法**：
  1. 检查是否安装了 `mineru-open-api` CLI 命令：`which mineru-open-api 2>/dev/null && mineru-open-api --version`
  2. 如果未找到，检查 MCP 工具列表中是否有 `mcp__mineru__*` 相关工具
  3. 如果都不可用，使用 fallback
- **调用方式**：
  ```
  # 提取 PDF 为 Markdown（输出到临时目录）
  mineru-open-api extract "论文文件路径" -o ./_paper_output/ -f md
  
  # 或直接输出到 stdout
  mineru-open-api extract "论文文件路径" -f md
  ```
  - 支持格式：PDF、图片（png/jpg）、Doc、Docx、Ppt、Pptx、Html
  - 文件限制：最大 200MB，最多 600 页
  - 输出格式：md（默认）、json、html、latex、docx
  - 支持批处理：`mineru-open-api extract *.pdf -o ./results/`
- **提取后处理**：
  1. 如果输出到文件，使用 Read 工具读取提取后的 Markdown 文件
  2. 如果输出到 stdout，直接使用提取的文本
  3. 清理临时文件（如果适用）
- **Fallback**：如果 MinerU 不可用或提取失败，礼貌地告知用户并要求粘贴纯文本
  ```
  检测到 MinerU 当前不可用。请直接粘贴论文的文本内容，或者使用 PDF 阅读器复制文本后粘贴。
  ```

### Claude-Obsidian Wiki（可选 — 推荐启用）
- **作用**：将论文总结深度集成到 Obsidian wiki 知识图谱中
- **Wiki 化功能**：
  1. **实体提取与页面创建**：从论文中提取作者、机构、关键方法/模型名，自动创建或更新 `wiki/entities/` 下的实体页面
  2. **概念提取与页面创建**：提取核心技术概念、理论框架，自动创建或更新 `wiki/concepts/` 下的概念页面
  3. **交叉引用**：自动与新生成的论文总结页面建立 `[[wiki-link]]` 双向链接
  4. **索引更新**：更新 `wiki/index.md` 和领域子索引
  5. **hot.md 更新**：记录最近的论文总结上下文，保持热缓存
  6. **log.md 记录**：记录本次论文总结操作，便于追溯
  7. **矛盾检测**：如果新论文观点与已有 wiki 页面冲突，添加 `[!contradiction]` 标注
- **Wiki 格式化增强**：
  - Frontmatter 增加 `address:` 字段（DragonScale 地址，如果启用）
  - 论文总结页面自动归类到 `wiki/sources/` 或 PARA 对应文件夹
  - 为每个关键实体生成存根页面（stub page），便于后续扩展
- **检测方法**：
  1. 检查当前 vault 中是否存在 `wiki/` 目录
  2. 检查是否存在 `.vault-meta/mode.json`
  3. 如果存在，记录 wiki 模式（generic/PARA/LYT/zettelkasten）
- **Fallback**：如果 wiki 未设置，使用标准 Write 保存，不做 wiki 化

### Obsidian Vault（可选）
- **作用**：将生成的 Markdown 文件保存到用户的 Obsidian vault
- **默认行为**：自动检测当前打开的 vault，直接保存，无需用户选择路径
- **检测方法**（按优先级）：
  1. **优先级 1（最高）**：检测当前打开的 vault
     - **检测当前工作目录**：使用 `pwd` 获取当前目录
     - **向上查找 `.obsidian/` 目录**：从当前目录开始，逐级向上查找父目录，直到找到包含 `.obsidian/` 的目录
     - **验证**：如果找到 `.obsidian/`，该目录即为当前打开的 vault 根目录
     - **示例**：
       ```bash
       当前目录：H:/Obsidian/LGY-Obsidian/wiki/sources/
       向上查找：
       - H:/Obsidian/LGY-Obsidian/wiki/sources/ ✗ 无 .obsidian/
       - H:/Obsidian/LGY-Obsidian/wiki/ ✗ 无 .obsidian/
       - H:/Obsidian/LGY-Obsidian/ ✓ 找到 .obsidian/
       检测到 vault：H:/Obsidian/LGY-Obsidian/
       ```
     - **如果当前在 vault 内**：直接使用检测到的 vault，默认保存到当前目录或 vault 根目录
  2. **优先级 2**：检查用户记忆中是否已记录 Obsidian vault 路径
     - 读取 `~/.claude/projects/<project>/memory/` 下的记忆文件
     - 搜索包含 "obsidian" 或 "vault" 关键词的路径
  3. **优先级 3**：检查常见的 Obsidian vault 位置
     - `~/Obsidian/`
     - `~/Documents/Obsidian/`
     - `~/OneDrive/Obsidian/` 或 `~/OneDrive - */Obsidian/`（Windows OneDrive）
     - `H:/Obsidian/`（根据 MEMORY.md 中的用户记忆）
  4. **优先级 4**：询问用户
     ```
     未检测到 Obsidian vault。请选择：
     1. 手动指定路径
     2. 不保存文件，直接在对话中显示
     
     请选择一个选项（输入 1/2）：
     ```
- **默认保存行为**（优先级 1 检测成功时）：
  - 如果当前在 vault 的某个子目录下（如 `wiki/sources/`），默认保存到当前子目录
  - 如果当前在 vault 根目录，询问用户选择子目录或保存到根目录
  - **不再询问是否保存**，直接保存并确认
- **Fallback**：如果所有检测都失败，直接在对话中输出完整 Markdown
  ```
  以下是生成的论文总结 Markdown，您可以复制后手动保存到 Obsidian vault：
  
  [显示完整 Markdown]
  ```
- **保存后验证**：
  - 保存文件后，检查文件是否成功创建
  - 显示文件的完整路径（相对于 vault 根目录）
  - 提示用户：`✓ 已保存到：[相对路径]`

---

## 工作流概览

```
用户输入
  ├── 单篇论文（PDF/文本/URL）→ 单篇模式
  │     ↓
  │   [可选] MinerU 提取全文（PDF/Word/图片）
  │     ↓
  │   FOCUS 阶段A：逐段抽取（含细节、引文、指标）
  │     ↓
  │   FOCUS 阶段B：清理、结构化、添加概述
  │     ↓
  │   Obsidian 格式化（frontmatter + wiki-link）
  │     ↓
  │   [可选] 导出 Markdown 到 Obsidian vault 或显示在对话中
  │
  └── 文件夹路径 / 多个文件 → 批量模式
        ↓
      扫描文件夹 → 发现 N 个论文文件
        ↓
      批量 MinerU 提取（容错跳过失败文件）
        ↓
      顺序执行 FOCUS 阶段A+B（每篇独立）
        ↓
      保存每篇总结 + 生成批量索引
        ↓
      [可选] 批量 Wiki 化（实体/概念去重合并）
```

---

## 使用方法

### 触发方式

在对话中输入以下任一指令：

```
/summarize-paper
总结论文
学术论文分析
提取论文核心内容
详细论文摘要
使用FOCUS方法分析这篇论文
```

### 用户输入方式

**选项 1：单篇论文（PDF/Word/图片）**
```
用户：/summarize-paper
+ 上传 paper.pdf（或 paper.docx、paper.png）
```

**选项 2：粘贴纯文本**
```
用户：/summarize-paper
+ 粘贴论文的完整文本
```

**选项 3：提供 URL**
```
用户：/summarize-paper
输入：https://example.com/paper.pdf
```

**选项 4：批量处理 — 提供文件夹路径**
```
用户：/summarize-paper ~/Downloads/papers/
或
用户：/summarize-paper --recursive ~/Downloads/papers/
```
> Skill 自动检测到文件夹路径，进入批量处理模式，依次总结文件夹内的所有论文。

**选项 5：批量处理 — 上传多个文件**
```
用户：/summarize-paper
+ 上传 paper1.pdf, paper2.pdf, paper3.docx
```
> Skill 检测到多个文件（≥2），自动进入批量处理模式。

---

## 执行步骤（必须严格遵循）

### 步骤 0：输入处理与依赖检测

#### 0.1 MinerU 可用性检测

**执行一次性检测（每个会话只检测一次）：**

1. **检查 CLI 命令**（优先）
   ```bash
   which mineru-open-api 2>/dev/null && mineru-open-api --version 2>/dev/null
   ```
   - 如果返回版本号：记录 MinerU 状态为"可用（CLI）"

2. **检查 MCP 工具列表**（备选）
   - 查看当前可用的工具列表中是否有以 `mcp__mineru__*` 开头的工具
   - 如果找到：记录 MinerU 状态为"可用（MCP）"

3. **检测结果处理**
   - **如果 MinerU CLI 可用**：
     ```
     ✓ 检测到 MinerU CLI 可用，可以直接处理 PDF/Word/图片文件。
     ```
     记录 MinerU 状态为"可用（CLI）"
   
   - **如果 MinerU MCP 可用**：
     ```
     ✓ 检测到 MinerU MCP 可用，可以处理 PDF/Word/图片文件。
     ```
     记录 MinerU 状态为"可用（MCP）"
   
   - **如果都不可用**：
     ```
     ⚠ MinerU 当前不可用。如果您上传 PDF/Word/图片，我会引导您粘贴文本内容。
     ```
     记录 MinerU 状态为"不可用"

4. **如果用户上传了 PDF/Word/图片**
   - **MinerU CLI 可用时**：
     ```bash
     mineru-open-api extract "用户上传的文件路径" -o ./_paper_output/ -f md
     ```
     然后使用 Read 工具读取 `./_paper_output/` 中的 Markdown 文件
   
   - **MinerU MCP 可用时**：
     调用对应的 MCP 工具提取
   
   - **都不可用时**：
     ```
     MinerU 当前不可用。请使用 PDF 阅读器打开文件，复制全文后粘贴。
     或者如果文件较短，可以直接描述主要内容。
     ```

#### 0.2 Obsidian Vault 路径检测

**执行智能检测（按优先级）：**

1. **优先级 1（最高）：检测当前打开的 vault**
   
   **目标**：如果用户正在 Obsidian vault 内工作（例如在某个笔记目录下），自动检测当前 vault。
   
   **检测步骤**：
   ```bash
   # 1. 获取当前工作目录
   CURRENT_DIR=$(pwd)
   
   # 2. 向上查找 .obsidian/ 目录
   DIR="$CURRENT_DIR"
   VAULT_ROOT=""
   while [ "$DIR" != "/" ] && [ "$DIR" != "." ]; do
       if [ -d "$DIR/.obsidian" ]; then
           VAULT_ROOT="$DIR"
           break
       fi
       DIR=$(dirname "$DIR")
   done
   
   # 3. 如果找到
   if [ -n "$VAULT_ROOT" ]; then
       echo "✓ 检测到当前 vault：$VAULT_ROOT"
       # 记录 vault 根目录和当前子目录
       RELATIVE_DIR="${CURRENT_DIR#$VAULT_ROOT/}"
   fi
   ```
   
   **示例**：
   ```
   当前目录：H:/Obsidian/LGY-Obsidian/wiki/sources/
   向上查找：
   - H:/Obsidian/LGY-Obsidian/wiki/sources/ ✗ 无 .obsidian/
   - H:/Obsidian/LGY-Obsidian/wiki/ ✗ 无 .obsidian/
   - H:/Obsidian/LGY-Obsidian/ ✓ 找到 .obsidian/
   
   结果：
   ✓ 检测到当前 vault：H:/Obsidian/LGY-Obsidian/
   ✓ 当前子目录：wiki/sources/
   ✓ 默认保存位置：wiki/sources/（当前目录）
   ```
   
   **检测结果处理**：
   - **如果检测成功**：
     ```
     ✓ 检测到当前打开的 vault：[vault根目录]
     ✓ 当前位置：[相对路径]
     ✓ 将自动保存到当前目录
     ```
     记录 vault 根目录、当前子目录，并标记为"当前vault"（优先级最高）

2. **优先级 2：检查用户记忆**
   - 读取 `~/.claude/projects/<current-project>/memory/MEMORY.md`
   - 搜索包含 "Obsidian"、"vault"、"笔记库" 的记忆条目
   - 如果找到，读取对应的记忆文件获取 vault 路径
   - **如果优先级 1 检测成功，此步骤仍执行**，但仅作为备份参考

3. **优先级 3：检查常见位置**（按顺序尝试）
   ```
   检测路径：
   1. ~/Obsidian/
   2. ~/Documents/Obsidian/
   3. ~/OneDrive/Obsidian/
   4. ~/OneDrive - */Obsidian/（匹配任何 OneDrive 组织）
   5. H:/Obsidian/（根据 MEMORY.md，用户可能使用 H: 盘）
   ```
   
   对每个路径执行：
   - 使用 Bash 工具检查目录是否存在：`test -d "路径" && echo "exists"`
   - 如果存在，检查是否包含 `.obsidian/` 子目录（确认是 Obsidian vault）

4. **检测结果处理（优先使用优先级 1）**
   - **如果优先级 1 检测到当前 vault**：
     ```
     ✓ 检测到当前打开的 vault：[路径]
     ✓ 默认保存位置：[当前子目录或vault根目录]
     ```
     直接使用，不询问用户
   
   - **如果仅优先级 2/3 找到 vault**：
     ```
     ✓ 检测到 Obsidian vault（从记忆/常见位置）：[路径]
     稍后会询问保存子目录。
     ```
     记录 vault 路径，但需要询问子目录
   
   - **如果找到多个 vault（不含当前vault）**：
     ```
     ✓ 检测到多个 Obsidian vault：
     1. [路径1]
     2. [路径2]
     稍后会让您选择保存位置。
     ```
     记录所有 vault 路径列表
   
   - **如果未找到 vault**：
     ```
     ⚠ 未检测到 Obsidian vault。稍后会询问是否手动指定路径，或直接在对话中显示结果。
     ```
     记录 vault 状态为"未找到"

#### 0.3 检测输入类型并处理

1. **识别用户输入**
   - 如果用户提供了文件夹路径（目录存在，非文件路径）：
     * **自动进入批量处理模式**（详见 §批量文件夹处理模式）
     * 跳转到步骤 B0：文件扫描与发现
   - 如果用户一次性上传了多个文件（≥2 个 PDF/Word/图片）：
     * **自动进入批量处理模式**
     * 跳转到步骤 B0，将多文件列表作为待处理列表
   - 如果用户上传了单个 PDF/Word/图片：
     * **检查 MinerU 状态**
     * 如果可用：调用 MinerU 提取工具
     * 如果不可用或提取失败：
       ```
       MinerU 当前不可用。请使用 PDF 阅读器打开文件，复制全文后粘贴。
       或者如果文件较短，可以直接描述主要内容。
       ```
   - 如果用户粘贴了文本：直接使用
   - 如果用户提供了 URL：
     * 使用 WebFetch 或 Bash 工具下载文件
     * 然后按 PDF/Word/图片逻辑处理

2. **确认论文语言**
   - 自动检测论文主要语言（中文/英文/其他）
   - 输出始终使用中文
   - 如果论文是非中英文（如日语、韩语），提示用户：
     ```
     检测到论文使用 [语言]。我会尽力处理，但建议您提供英文版本以获得最佳效果。
     ```

#### 0.4 检测总结（在继续前向用户确认）

```
=== 环境检测结果 ===
MinerU：[✓ 可用 / ⚠ 不可用]
Obsidian Vault：[✓ 已检测到：路径 / ⚠ 未检测到]
Claude-Obsidian Wiki：[✓ 已配置：模式 / ⚠ 未配置]
论文语言：[检测到的语言]
输入方式：[PDF文件 / 文本粘贴 / URL]

准备开始 FOCUS 分析...
```

#### 0.5 Claude-Obsidian Wiki 可用性检测

**执行一次性检测：**

1. **检测 wiki 目录结构**
   ```bash
   # 检查 vault 中是否有 wiki/ 目录
   test -d "$VAULT_ROOT/wiki/" && echo "wiki directory exists" || echo "no wiki directory"
   
   # 检查关键文件
   test -f "$VAULT_ROOT/wiki/index.md" && echo "index exists" || echo "no index"
   test -f "$VAULT_ROOT/wiki/hot.md" && echo "hot cache exists" || echo "no hot cache"
   test -f "$VAULT_ROOT/wiki/log.md" && echo "log exists" || echo "no log"
   ```

2. **检测 wiki 模式**
   ```bash
   # 检查模式文件
   cat "$VAULT_ROOT/.vault-meta/mode.json" 2>/dev/null || echo "{\"mode\":\"generic\"}"
   ```
   - 支持的模式：`generic`、`PARA`、`LYT`、`zettelkasten`
   - 如果未设置，默认为 `generic`

3. **检测结果处理**
   - **如果 wiki 已配置**：
     ```
     ✓ 检测到 Claude-Obsidian Wiki：已配置（模式：[generic/PARA/LYT/zettelkasten]）
     ✓ 论文总结将深度集成到知识图谱中
     ```
     记录 wiki 状态为"已配置"
   
   - **如果 wiki 未配置**：
     ```
     ⚠ 未检测到 Claude-Obsidian Wiki。
     论文总结将以普通 Markdown 文件保存（不含 wiki 化增强）。
     
     如需启用 wiki 化功能，运行：claude-obsidian:wiki
     ```
     记录 wiki 状态为"未配置"

4. **wiki 已配置时的额外处理**
   - 在步骤 4 中执行完整的 wiki 化流程（实体/概念提取 + 交叉引用 + 索引更新）
   - 保存到 wiki 路径由模式决定：
     * generic/PARA：`wiki/sources/`
     * LYT：`wiki/notes/`
     * zettelkasten：`wiki/`（带时间戳 ID）

---

### 步骤 1：FOCUS 阶段 A — 逐段详细提取

**目标**：从论文中提取所有关键信息，不遗漏细节。

**执行逻辑**：

1. **文档分章节**
   - 识别论文结构：Abstract, Introduction, Related Work, Methods, Experiments, Results, Discussion, Limitations, Conclusion
   - 如果论文没有明确章节标题，按段落逻辑分组

2. **逐段提取关键点**
   对每个段落或小节，提取以下信息：
   
   - **核心结论（Claim）**：这段话的主要观点是什么？
   - **量化指标**：所有数字、百分比、p-value、置信区间、F1-score、准确率等
   - **方法细节**：模型名称（如 BERT-base）、算法步骤、数据集名称（如 ImageNet-21K）、版本号
   - **关键公式**：论文中的核心数学公式，必须保留 LaTeX 格式
     * 使用标准 LaTeX 数学模式：`$...$`（内联）或 `$$...$$`（独立）
     * 标注公式编号（如果论文中有）：如 Eq. (3)、(5)
     * 简要说明符号含义
   - **对比与消融**：
     * 与 baseline 的对比（如 "vs. Method-A"）
     * 消融研究（如 "去掉注意力机制后，性能下降 15%"）
   - **关键原文引用**：每个章节最多提取 0-2 句高信息量的原句（不编造，不改写）
   - **来源位置**：标注信息来自哪个章节或段落

3. **保留所有细节**
   - 不要省略任何量化数据、方法名、数据集版本
   - 不要总结或改写具体数字
   - 如果原文提到 "N = 2,847"，必须保留这个精确数字
   - 如果原文提到 "AdamW 优化器，学习率 0.001"，必须完整保留
   - **必须保留所有关键公式的 LaTeX 格式**，不要用自然语言代替

4. **输出格式（内部中间结果，用户不可见）**
   ```markdown
   ## [章节名，如 Methods]
   
   1. **主要结论**：使用多头注意力机制（48个头）处理MSA特征
      - 量化指标：隐层维度384，参数总数2.3亿
      - 方法细节：Transformer编码器，初始embedding维度64
      - 原文引用：_"多头注意力机制对多序列比对深度特征的挖掘，是相比传统方法的最关键创新"_
      - 来源位置：Methods 第2段

   2. **另一项关键信息**：...
   ```

**重要**：这个阶段的输出是内部中间结果，不直接展示给用户。

---

### 步骤 2：FOCUS 阶段 B — 清理与结构化

**目标**：将阶段 A 的原始提取清单，重组为逻辑清晰、易读的结构化摘要。

**执行逻辑**：

1. **去除冗余引用标记**
   - 移除 `[ref:1]`、`(Author et al., 2023)` 等文献引用标记
   - 保留关键数据和直接引文

2. **按逻辑主题重组**
   将阶段 A 的提取项，按以下主题分组（每个主题 5-10 个要点）：
   - 贡献与关键发现
   - 方法
   - 实验设置与数据集
   - 实验结果
   - 消融研究
   - 局限性
   - 启发与未来工作

3. **为每个主题生成概述**
   在每个主题开头，添加 3-6 句总结：
   - 简洁概括该主题的核心内容
   - 包含 1-2 条关键指标
   - 说明为什么重要

4. **Obsidian 格式化**
   - **Frontmatter**：生成 YAML 格式的元数据（见下方示例）
   - **Wiki-link 转换**：
     * 识别论文中的关键术语（模型名、数据集名、方法名、相关论文标题）
     * 转换为 `[[术语]]` 格式
     * 例：`使用 BERT 在 ImageNet 上训练` → `使用 [[BERT]] 在 [[ImageNet]] 上训练`
   - **反向链接提示**：
     * 在末尾添加 "相关论文" 部分，使用 wiki-link 格式
     * 例：`- [[AlphaFold论文]]`、`- [[Transformer综述]]`

5. **质量检查**
   在生成输出前，自我检查：
   - [ ] 所有量化指标已保留（n值、p-value、百分比）
   - [ ] 所有方法名、模型名、数据集名已保留
   - [ ] 所有关键公式已保留（LaTeX 格式，用 $...$ 或 $$...$$ 包裹）
   - [ ] 所有关键对比已保留
   - [ ] 无编造引文（仅使用原文）
   - [ ] Frontmatter 格式正确
   - [ ] Wiki-link 已转换
   - [ ] UTF-8 编码（中文无乱码）
   - [ ] LaTeX 公式语法正确，可在 Obsidian 中渲染

---

### 步骤 3：生成最终输出

**输出格式**：严格按照以下结构生成 Markdown。

---

## 输出格式示例（必须严格遵循）

```markdown
---
title: 用Transformer进行蛋白质结构预测
authors: 
  - Smith, J.
  - Johnson, K.
publication: Nature 2023
year: 2023
url: https://doi.org/10.1038/s41586-023-xxxxx
tags: 
  - 生物信息学
  - 深度学习
  - 蛋白质预测
  - Transformer
created: 2024-01-15
updated: 2024-01-15
related_papers:
  - "[[AlphaFold论文]]"
  - "[[Transformer综述]]"
---

# 论文总结：用Transformer进行蛋白质结构预测

## 概述

本论文提出了一种新型Transformer架构，在CASP14基准测试中达到 **85.3 Å pLDDT**，相比现有最优方法（62.5 Å）提升了**45%**。核心创新在于多头注意力机制对多序列比对（MSA）的深度挖掘，首次实现了完全端到端的可微分结构预测。该工作对蛋白质工程、药物发现、生物学基础研究具有重要意义。

---

## 1. 贡献与关键发现

> **概述**：本节总结论文的三大核心创新：新型Transformer架构、性能突破（CASP14 benchmark +45%）、完全自动化流程。这些创新使该方法成为当前蛋白质结构预测领域的SOTA。

1. **新型Transformer架构**
   - 多头注意力（48个头）直接作用于MSA特征
   - 隐层维度384，这与此前分离处理序列和结构的方法显著不同
   - 首次实现端到端可微分预测

2. **性能突破**
   - CASP14 benchmark：**85.3 Å**（vs. 62.5 Å baseline，+45%）
   - 困难目标（TM-score < 0.5）上的改进：**38%**
   - 这表明该方法对新折叠特别有效

3. **完全自动化流程**
   - 不依赖同源序列数据库
   - 仅从蛋白质序列本身进行预测

---

## 2. 方法

> **概述**：方法部分包含三大模块：多序列比对预处理（MSA聚类 + Transformer编码）、结构预测模块（二面角 + Cα-Cα距离）、推理加速（蒸馏到轻量模型）。参数总数2.3亿，训练在8×V100上耗时3周。

1. **多序列比对预处理**
   - 聚类MSA：128个序列/蛋白质，最大深度10,000
   - [[Transformer]]编码器：初始embedding维度64，48个注意力头，隐层384
   - 参数总数：2.3亿

2. **结构模块与损失函数**
   - 预测二面角（$\phi$、$\psi$、$\omega$）和 $C_\alpha$-$C_\alpha$ 距离
   - 训练损失：
     $$\mathcal{L} = \lambda_1 \mathcal{L}_{\text{MLM}} + \lambda_2 \mathcal{L}_{\text{structure}}$$
     其中 $\lambda_1 = 0.01$ 为 masked language model loss 权重
   - 优化器：[[AdamW]]，学习率 $0.001$，batch size 512

3. **推理加速**
   - 蒸馏到轻量模型（2000万参数）
   - 推理时间：单个蛋白质 ~2分钟（GPU）

---

## 3. 实验结果

> **概述**：在[[CASP14]]基准测试中，本方法达到85.3 Å pLDDT，相比现有方法（62.5 Å）提升45%。困难目标改进38%，表明对新折叠的泛化能力强。推理时间从12分钟降至2分钟。

1. **CASP14基准测试**
   - **整体pLDDT：85.3 Å**（现有最优62.5 Å）
   - 困难目标显著改进：TM-score < 0.5 的目标改进38%
   - 表明模型对新结构/新折叠的泛化能力强

2. **与其它方法对比**
   | 方法 | pLDDT | F1-score | 推理时间 |
   |-----|-------|---------|--------|
   | 本方法 | 85.3 | 0.91 | 2.1 min |
   | Baseline-A | 62.5 | 0.76 | 12 min |
   | Baseline-B | 70.1 | 0.82 | 8 min |

---

## 4. 消融研究

> **概述**：消融研究验证了注意力头数和MSA深度对性能的影响。48个注意力头时达到最优（85.3 pLDDT），减少头数或MSA深度均导致性能下降。

1. **注意力头数**
   - 48头：85.3 pLDDT
   - 24头：82.1 pLDDT（-3.2）
   - 12头：79.5 pLDDT（-5.8）
   - **结论**：注意力头数对性能影响显著

2. **MSA深度影响**
   - Max depth 10,000：85.3 pLDDT
   - Max depth 5,000：84.1 pLDDT（-1.2）
   - Max depth 1,000：81.7 pLDDT（-3.6）

---

## 5. 数据集与实现细节

- **训练集**：[[PDB]]（Protein Data Bank）中的67,000个蛋白质结构
- **评估集**：[[CASP14]]官方测试集（87个目标）
- **评估指标**：pLDDT（置信度分数）、TM-score（结构相似度）
- **硬件**：8×V100 GPU，训练时长3周
- **代码**：GitHub 公开（https://github.com/example/protein-transformer）

---

## 6. 局限性

1. **作者明确提及**
   - 对同源序列丰富的蛋白质预测效果更好；当MSA样本量过少时，性能下降
   - 对某些病毒蛋白预测不足（数据训练不足）

2. **推断的局限**
   - 仅预测单体结构，暂不支持复杂体系
   - 模型在极端pH/温度条件下未测试
   - 蒸馏模型性能相对下降5-8%

---

## 7. 可复现性清单

- [x] 数据集获取与版本信息齐全
- [x] 关键预处理步骤明确
- [x] 模型结构与损失函数明确
- [x] 超参（batch size、学习率、epoch）、硬件（V100×8）、训练时长（3周）都提供
- [x] 评估指标定义清晰
- [x] 代码与权重文件公开
- [ ] 未提供：不同团队的重复实验结果对比

---

## 8. 高价值原文摘录

> _"多头注意力机制对多序列比对深度特征的挖掘，是相比传统方法的最关键创新"_  
> **来源**：Methods 段落  
> **为什么高价值**：清晰指出了核心技术差异

> _"在困难目标上的改进幅度达38%，表明该方法对新折叠的泛化能力强"_  
> **来源**：Results 表格2  
> **为什么高价值**：量化指标，直接体现优势所在

> _"推理时间从12分钟降至2分钟，使大规模高通量预测成为可能"_  
> **来源**：Discussion  
> **为什么高价值**：阐明了应用价值和工程意义

---

## 9. 我的笔记与关联

### 相关论文
- [[AlphaFold-论文总结]] - 对比参考
- [[Transformer架构综述]]
- [[蛋白质结构预测综述]]

### 关键概念
- [[多序列比对（MSA）]] 
- [[pLDDT置信度分数]]
- [[TM-score]]

### 启发与后续思考
- 该方法是否能推广到RNA二级结构预测？
- 如何优化对小蛋白的预测性能？
- 与[[Rosetta软件]]或[[FoldX]]的对比如何？

---

## 可操作的后续步骤

1. [ ] 精读 Methods 部分（理解Transformer细节）
2. [ ] 复现 Figure 3（消融研究）
3. [ ] 在自己的蛋白质数据上测试
4. [ ] 与团队分享核心发现

---

## 质量控制报告

### 覆盖范围
- [x] 贡献与发现
- [x] 方法详解
- [x] 实验与结果
- [x] 消融研究
- [x] 局限性分析
- [x] 可复现清单

### 细节保留
- [x] 所有量化指标已保留（n值、p-value、百分比）
- [x] 所有方法名与模型名已保留
- [x] 所有关键比较已保留
- [x] 无编造引文

### Obsidian 就绪
- [x] Frontmatter 完整
- [x] wiki-link 已转换
- [x] 反向链接提示已生成
- [x] UTF-8 编码正确

### 可导出性
- [x] Markdown 语法有效
- [x] 文件名安全（无特殊字符）
- [x] 路径编码正确
```

---

## 步骤 4：导出、Wiki 化与保存

### 4.1 根据检测结果选择保存策略

**决策树**：

```
Claude-Obsidian Wiki 是否已配置？
├── 是 → 执行 §4.2 Wiki 化保存（完整知识图谱集成）
└── 否 → 执行 §4.3 普通保存（仅写文件）
```

检测结果在步骤 0.2（vault）和步骤 0.5（wiki）中已记录。

---

### 4.2 Wiki 化保存（wiki 已配置时）

**前置条件**：步骤 0.5 检测到 `wiki/` 目录和 wiki 索引文件。

**流程概览**：

```
保存论文总结主页面
  ↓
提取实体 → 创建/更新 wiki/entities/ 页面
  ↓
提取概念 → 创建/更新 wiki/concepts/ 页面
  ↓
交叉引用（[[wiki-link]] 双向链接）
  ↓
更新 wiki/index.md
  ↓
更新 wiki/hot.md（热缓存）
  ↓
记录 wiki/log.md
```

**完整执行步骤**：

#### 4.2.1 保存论文总结主页面

1. **确定保存路径**（按 wiki 模式）
   - generic/PARA 模式：`{vault根}/wiki/sources/{文件名}`
   - LYT 模式：`{vault根}/wiki/notes/{文件名}`
   - zettelkasten 模式：`{vault根}/wiki/{YYYYMMDDHHmmss}-{文件名}`

2. **生成文件名**
   - 格式：`{论文标题}_{YYYY-MM-DD}.md`
   - 清理特殊字符：移除 `/`、`\`、`:`、`*`、`?`、`"`、`<`、`>`、`|`
   - 限制长度：最多 100 个字符

3. **增强 Frontmatter**（在标准 frontmatter 基础上增加 wiki 字段）
   ```yaml
   ---
   title: "论文标题"
   authors: [作者列表]
   publication: "期刊/会议"
   year: 2026
   url: "DOI链接"
   tags: [标签列表]
   created: 2026-06-05
   updated: 2026-06-05
   # 以下为 wiki 增强字段
   source_type: "academic-paper"
   entities:  # 从论文中提取的关键实体
     - "[[实体1]]"
     - "[[实体2]]"
   concepts:  # 从论文中提取的核心概念
     - "[[概念1]]"
     - "[[概念2]]"
   related_papers:
     - "[[相关论文1]]"
     - "[[相关论文2]]"
   ---
   ```

4. **检查文件冲突**（同普通保存逻辑）
   - 不存在 → 直接写入
   - 己存在 → 询问覆盖/追加版本号/取消

5. **写入文件**：使用 Write 工具

#### 4.2.2 提取实体并创建/更新页面

**从论文总结中提取以下实体**：

| 实体类型 | 示例 | wiki 目标路径 |
|---------|------|-------------|
| 作者（第一/通讯作者） | Strack, O.D.L. | `wiki/entities/O.D.L.-Strack.md` |
| 机构 | University of Minnesota | `wiki/entities/University-of-Minnesota.md` |
| 关键方法/模型 | AEM, Transformer | `wiki/entities/AEM.md` |
| 关键软件/工具 | MODFLOW, Python | `wiki/entities/MODFLOW.md` |
| 数据集 | CASP14, ImageNet | `wiki/entities/CASP14.md` |

**对每个实体执行**：

1. **检查是否已有页面**
   ```bash
   test -f "wiki/entities/实体名.md" && echo "exists" || echo "new"
   ```

2. **如果不存在**：创建存根页面（stub page）
   ```markdown
   ---
   title: "实体名"
   entity_type: "person" | "organization" | "method" | "software" | "dataset"
   source: "[[论文标题_日期]]"
   created: YYYY-MM-DD
   updated: YYYY-MM-DD
   tags: [相关标签]
   ---
   
   # 实体名
   
   ## 概述
   
   [从论文中提取的简要描述]
   
   ## 相关知识
   
   - 来源论文：[[论文标题_日期]]
   - 关联概念：[[关联概念]]
   
   > [!note] 存根页面
   > 此页面由学术论文总结自动生成，内容有限。欢迎扩展。
   ```

3. **如果已存在**：追加引用段落（不覆盖已有内容）
   ```markdown
   ## 论文引用
   
   - [[论文标题_日期]]：[论文中提到的相关信息]
   ```

#### 4.2.3 提取概念并创建/更新页面

**从论文总结中提取核心技术概念**（3-8 个）：

```
论文：Theory and Applications of the Analytic Element Method
概念提取示例：
- Analytic Element Method (AEM)
- Groundwater Flow Modeling
- Complex Potential Theory
- Boundary Conditions
- Line Elements
- Superposition Principle
```

**对每个概念执行**：

1. **检查是否已有页面**
2. **如果不存在**：创建概念存根页面
3. **如果已存在**：追加论文引用
4. **建立与实体的关联**：`> 相关实体：[[实体1]], [[实体2]]`

#### 4.2.4 交叉引用

**在论文总结主页面中**：
- 确保所有实体引用使用 `[[wiki-link]]` 格式
- 确保所有概念引用使用 `[[wiki-link]]` 格式
- 添加"相关论文"部分的 wiki-link

**在已更新的实体/概念页面中**：
- 在论文引用部分添加反向链接：`- [[论文标题_日期]]`

**矛盾检测**：
- 检查新论文观点是否与已有 wiki 页面冲突
- 如果冲突，在两方页面添加 `> [!contradiction]` 标注

#### 4.2.5 更新 wiki/index.md

**追加新条目到索引**：

```markdown
### 论文总结

- [[论文标题_日期]] — [一句话概述]（[年份]）
```

**更新概念索引**（如果创建了新概念页面）：

```markdown
### 概念

- [[新概念1]] — [定义简述]
- [[新概念2]]
```

**更新实体索引**（如果创建了新实体页面）：

```markdown
### 实体

- [[新实体1]] — [类型: person/method/software]
```

#### 4.2.6 更新 wiki/hot.md（热缓存上下文）

**追加当前上下文到 hot.md**：

```markdown
## [YYYY-MM-DD] 论文总结 | 论文标题

- 论文：[[论文标题_日期]]
- 核心概念：[[概念1]], [[概念2]], [[概念3]]
- 关键实体：[[实体1]], [[实体2]]
- 新建页面：[[页面1]], [[页面2]]
- 更新页面：[[页面3]], [[页面4]]
- 关键发现：[一句话核心贡献]
```

#### 4.2.7 记录 wiki/log.md

**在 log.md 顶部追加**：

```markdown
## [YYYY-MM-DD] academic-paper-summary | 论文标题
- 论文：[论文标题]（[年份]）
- 总结页面：[[论文标题_日期]]
- 新建实体：[[实体1]], [[实体2]]
- 新建概念：[[概念1]], [[概念2]]
- 更新页面：[[已有页面1]], [[已有页面2]]
- 来源：MinerU 提取 / 用户粘贴
```

#### 4.2.8 最终确认

```text
✓ 论文总结已保存并 Wiki 化！

文件位置：[wiki路径]/[文件名]
Wiki 集成：
- 新建实体页面：N 个
- 新建概念页面：M 个
- 更新已有页面：K 个
- 索引已更新：wiki/index.md
- 热缓存已更新：wiki/hot.md
- 操作已记录：wiki/log.md

提示：在 Obsidian 中按 Ctrl+O 打开，在图谱视图中查看关联。
```

---

### 4.3 普通保存（wiki 未配置时）

**适用场景**：步骤 0.5 未检测到 wiki 结构。

**当前 vault 检测到时**：自动保存到当前目录，无需询问。

```text
✓ 论文总结已生成！

检测到当前打开的 vault：[vault根目录]
当前位置：[相对于vault的路径]

正在保存到当前目录...
✓ 已保存到：[相对于vault根的路径]/[文件名]
文件大小：[大小]

提示：运行 claude-obsidian:wiki 启用知识图谱集成功能。
```

**从记忆/常见位置检测到 vault 时**：询问保存位置和子目录。

**未检测到 vault 时**：询问手动指定或显示 Markdown。

**保存逻辑**：与 §4.2.1 相同（不含 wiki 化增强）。

---

### 4.4 直接显示 Markdown

如果用户选择不保存或所有保存路径都无效：

```text
以下是生成的论文总结 Markdown：

---复制开始---

[完整 Markdown 内容]

---复制结束---

快速保存到 Obsidian：
1. 在 Obsidian 中按 Ctrl+N（新建笔记）
2. 粘贴上述内容，保存（Ctrl+S）
3. 建议文件名：{论文标题}_YYYY-MM-DD.md
```

---

### 4.5 错误处理

**如果写入失败**：检查路径权限，降级为显示 Markdown。
**如果 wiki 索引更新失败**：不阻断主流程，提示用户手动更新。
**如果 wiki-lock 获取失败**：等待 2 秒重试；再次失败则跳过该页面，记录到 log。

---

## 批量文件夹处理模式

> **适用场景**：当你需要对整个文件夹中的所有论文一次性生成总结，而非逐篇手动处理。适合文献综述初期、会议论文批量阅读、课题组论文归档等场景。

### 模式识别

**判断条件**（满足任一即进入批量模式）：
1. 用户提供了文件夹路径（而非单个文件路径）
2. 用户一次性上传了多个文件（≥2 个）
3. 用户明确表示要对整个文件夹或批量文件进行总结（如"总结文件夹里的论文"、"批量总结"等）

**确认检测结果**：
```
=== 检测到批量处理模式 ===
输入类型：文件夹路径 / 批量触发词 / 多文件上传
准备进入批量处理流程...
```

---

### 步骤 B0：文件扫描与发现

**执行扫描**：

使用 Bash 工具扫描目标文件夹中的所有支持格式：

```bash
# 扫描文件夹中的支持文件
find "目标文件夹路径" -maxdepth 1 -type f \( \
  -iname "*.pdf" -o \
  -iname "*.docx" -o \
  -iname "*.doc" -o \
  -iname "*.pptx" -o \
  -iname "*.ppt" -o \
  -iname "*.png" -o \
  -iname "*.jpg" -o \
  -iname "*.jpeg" \) \
  -exec ls -lh {} \; 2>/dev/null | sort

# 统计文件数量
FILE_COUNT=$(find "目标文件夹路径" -maxdepth 1 -type f \( -iname "*.pdf" -o -iname "*.docx" -o -iname "*.doc" -o -iname "*.pptx" -o -iname "*.ppt" -o -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | wc -l)
```

**递归模式（可选）**：

如果用户使用 `--recursive` 或 `-r` 参数，移除 `-maxdepth 1` 限制，递归扫描所有子文件夹：

```bash
# 递归扫描（含子文件夹）
find "目标文件夹路径" -type f \( \
  -iname "*.pdf" -o -iname "*.docx" -o -iname "*.doc" -o \
  -iname "*.pptx" -o -iname "*.ppt" -o \
  -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) \
  -exec ls -lh {} \; 2>/dev/null | sort
```

**展示扫描结果**：

```
=== 文件夹扫描结果 ===
路径：/path/to/folder
扫描模式：当前文件夹（非递归）

找到 5 个文件：

  1. Attention_Is_All_You_Need.pdf (2.3 MB)
  2. BERT_Pre-training_of_Deep_Bidirectional_Transformers.pdf (1.8 MB)
  3. GPT-3_Language_Models_are_Few-Shot_Learners.pdf (3.1 MB)
  4. ResNet_Deep_Residual_Learning_for_Image_Recognition.pdf (1.5 MB)
  5. ViT_An_Image_is_Worth_16x16_Words.pdf (2.7 MB)

预计总处理时间：约 10-15 分钟（基于文件大小估算）

是否继续批量处理？[Y/n]
```

**去重检查**：
- 检查输出目录中是否已有同名 `.md` 总结文件
- 如果已有，标记为"已存在"，询问是否跳过或覆盖
- 如果用户使用 `--skip-existing` 参数，自动跳过已生成总结的文件

**文件数过多警告**：
- 如果文件数 > 20：提示用户考虑分批处理
- 如果文件数 > 50：建议使用 `--recursive` 按子文件夹分批处理

---

### 步骤 B1：批量 MinerU 提取

**前置条件**：步骤 0.1 已完成 MinerU 可用性检测。

#### MinerU CLI 可用时

对每个文件依次调用 MinerU 提取，输出到统一临时目录：

```bash
# 创建批量输出目录
mkdir -p ./_batch_output/

# 对每个文件执行提取
for file in "文件1.pdf" "文件2.pdf" ...; do
  echo "[$N/$TOTAL] 提取中：$file"
  mineru-open-api extract "$file" -o "./_batch_output/$(basename "$file" | sed 's/\.[^.]*$//')/" -f md
done
```

#### MinerU MCP 可用时

逐个调用 MCP 工具提取，同样输出到 `_batch_output/`。

#### MinerU 不可用时

```
⚠ MinerU 当前不可用。

批量模式下，请选择一个替代方案：
1. 为每个文件手动粘贴论文文本（逐个处理）
2. 使用 PDF 阅读器批量导出文本后再处理
3. 仅处理少数重点论文，逐个粘贴

请输入选择（1/2/3）：
```

#### 容错处理

提取过程中单个文件失败不中断整体流程：

```
=== MinerU 提取进度 ===
[1/5] Attention_Is_All_You_Need.pdf ✓ 成功（提取 8,234 字）
[2/5] BERT.pdf ✓ 成功（提取 12,456 字）
[3/5] GPT-3.pdf ✗ 失败：文件已损坏，无法打开
[4/5] ResNet.pdf ✓ 成功（提取 9,123 字）
[5/5] ViT.pdf ✓ 成功（提取 7,890 字）

提取完成：4 成功，1 失败
失败列表：
  - GPT-3.pdf：文件已损坏，无法打开
```

---

### 步骤 B2：顺序 FOCUS 处理

**核心流程**：对每个成功提取的论文，依次执行完整的 FOCUS 两阶段分析。

**处理逻辑**：

1. 按文件名字母顺序或用户指定的顺序处理
2. 每篇论文独立执行完整的 FOCUS 流程（阶段 A + 阶段 B）
3. 每篇论文独立生成最终 Markdown 输出
4. 保存到输出目录（默认与源文件同目录，或用户指定的输出目录）

**进度展示**：

```
=== FOCUS 分析进度 ===

────────────────────────────────────────
[1/4] 处理中：Attention Is All You Need
────────────────────────────────────────
  ✓ 阶段 A：逐段提取完成（识别 6 个章节，提取 42 个关键点）
  ✓ 阶段 B：结构化完成（8 个主题组，质量检查通过）
  ✓ 已保存：Attention_Is_All_You_Need_2026-06-05.md

────────────────────────────────────────
[2/4] 处理中：BERT: Pre-training of Deep Bidirectional Transformers
────────────────────────────────────────
  ✓ 阶段 A：逐段提取完成（识别 7 个章节，提取 38 个关键点）
  ✓ 阶段 B：结构化完成（8 个主题组，质量检查通过）
  ✓ 已保存：BERT_2026-06-05.md

...
```

**容错处理**：
- 单篇 FOCUS 处理失败：记录错误原因，跳过该篇，继续处理下一篇
- 不因一篇论文的失败而中断整个批量流程

**中断与恢复**：
- 每处理完一篇论文，记录进度到 `_batch_progress.json`
- 如果用户中断（Ctrl+C），保留已完成的结果文件
- 下次重新执行时，检测 `_batch_progress.json`，跳过已处理的文件
- 进度文件格式：
  ```json
  {
    "folder": "/path/to/folder",
    "started": "2026-06-05T10:30:00",
    "total": 5,
    "completed": ["file1.pdf", "file2.pdf"],
    "failed": {"GPT-3.pdf": "文件已损坏"},
    "pending": ["ResNet.pdf", "ViT.pdf"]
  }
  ```

**大批量处理策略**：
- 文件数 ≤ 5：连续处理，不做暂停
- 文件数 6-15：每 5 篇暂停确认一次
- 文件数 > 15：每 10 篇暂停确认一次，并建议分批处理

---

### 步骤 B3：生成批量索引文件

在所有论文处理完毕后，在输出目录生成批量索引文件 `_batch_index_YYYY-MM-DD.md`：

**索引文件结构**：

```markdown
---
title: "批量论文总结索引"
date: 2026-06-05
folder: "/path/to/folder"
total: 5
succeeded: 4
failed: 1
tags: [batch-summary, paper-index]
created: 2026-06-05
---

# 批量论文总结索引

## 处理摘要

| 项目 | 详情 |
|------|------|
| 处理日期 | 2026-06-05 10:30 - 11:45 |
| 源文件夹 | `/path/to/folder` |
| 总计 | 5 篇 |
| 成功 | 4 篇 |
| 失败 | 1 篇 |
| MinerU 版本 | CLI v2.1.0 |
| 输出目录 | `/path/to/folder/` |

---

## 论文列表

| # | 论文标题 | 年份 | 核心主题 | 来源文件 | 总结文件 |
|---|---------|------|---------|---------|---------|
| 1 | [[Attention Is All You Need]] | 2017 | Transformer 架构、自注意力机制 | [Attention_Is_All_You_Need.pdf](Attention_Is_All_You_Need.pdf) | [总结](Attention_Is_All_You_Need_2026-06-05.md) |
| 2 | [[BERT]] | 2019 | 预训练语言模型、双向 Transformer | [BERT.pdf](BERT.pdf) | [总结](BERT_2026-06-05.md) |
| 3 | [[ResNet]] | 2016 | 深度残差学习、图像识别 | [ResNet.pdf](ResNet.pdf) | [总结](ResNet_2026-06-05.md) |
| 4 | [[ViT]] | 2021 | Vision Transformer、图像分类 | [ViT.pdf](ViT.pdf) | [总结](ViT_2026-06-05.md) |
| — | ~~GPT-3~~ | ~~2020~~ | ~~大规模语言模型~~ | ~~GPT-3.pdf~~ | ❌ 提取失败 |

---

## 跨论文主题分析

### 共同主题
- **Transformer 架构**：论文 #1, #2, #4 均基于 Transformer 或其变体
- **预训练-微调范式**：论文 #2, #3 均采用了预训练 + 下游任务微调的策略

### 方法对比

| 维度 | Attention Is All You Need | BERT | ViT |
|------|--------------------------|------|-----|
| 架构 | Encoder-Decoder | Encoder-only | Encoder-only |
| 参数量 | 65M / 213M | 110M / 340M | 86M / 307M |
| 核心创新 | 自注意力取代 RNN | 双向预训练 | Transformer 用于视觉 |
| 基准数据集 | WMT 2014 | GLUE / SQuAD | ImageNet-21K |

> **研究趋势观察**：从 2017 到 2021，Transformer 从 NLP 领域的序列建模工具，逐步演变为跨模态通用架构。参数规模也呈现显著增长趋势。

---

## 失败列表

| 文件 | 阶段 | 错误原因 |
|------|------|---------|
| GPT-3.pdf | MinerU 提取 | 文件已损坏，无法打开 |
```

---

### 步骤 B4：Wiki 化与最终确认

#### Wiki 化（Claude-Obsidian Wiki 已配置时）

对所有成功处理的论文，依次执行 §4.2 的 Wiki 化流程：
1. 逐个为论文总结页面添加 wiki 增强 frontmatter
2. 批量提取实体和概念（去重合并）
3. 创建/更新 wiki 实体页面和概念页面
4. 更新 `wiki/index.md`（批量添加条目）
5. 更新 `wiki/hot.md`（记录批量上下文）
6. 记录 `wiki/log.md`

```
=== Wiki 化进度 ===
[1/4] Attention Is All You Need → wiki/sources/ ✓
  新建实体：Vaswani, A.; Transformer; WMT 2014
  新建概念：Self-Attention; Multi-Head Attention; Positional Encoding
[2/4] BERT → wiki/sources/ ✓
  新建实体：Devlin, J.; Google AI; GLUE Benchmark
  新建概念：MLM; NSP; Bidirectional Pre-training
...
去重合并后：12 个实体页面，8 个概念页面
```

#### 最终确认

```
╔══════════════════════════════════════╗
║     ✅ 批量处理完成！               ║
╠══════════════════════════════════════╣
║ 总计：5 篇                          ║
║ 成功：4 篇                          ║
║ 失败：1 篇（GPT-3.pdf：提取失败）   ║
║                                    ║
║ 输出目录：/path/to/folder/          ║
║ 索引文件：_batch_index_2026-06-05.md║
║                                    ║
║ Wiki 集成：                         ║
║  - 新建实体页面：12 个              ║
║  - 新建概念页面：8 个               ║
║  - 索引已更新                       ║
║                                    ║
║ ⏱ 总耗时：约 15 分钟               ║
╚══════════════════════════════════════╝

快速浏览：
1. 打开 _batch_index_2026-06-05.md 查看索引
2. 在 Obsidian 图谱视图中探索关联

提示：如需重新处理失败的文件，修复后运行：
/summarize-paper --retry-failed GPT-3.pdf
```

---

### 步骤 B5：错误处理（批量模式专用）

| 错误类型 | 处理方式 |
|---------|---------|
| **MinerU 提取失败** | 跳过该文件，记录到失败列表，继续处理下一个 |
| **FOCUS 处理失败** | 跳过该论文，记录错误原因，继续处理 |
| **文件写入失败** | 检查磁盘空间和权限，暂停并警告用户 |
| **用户中断** | 保存当前进度到 `_batch_progress.json`，已完成的文件保留 |
| **磁盘空间不足** | 暂停处理，警告用户，提示清理空间 |
| **Wiki 索引更新失败** | 不阻断主流程，记录到错误日志，提示用户手动更新 |
| **全部文件提取失败** | 降级为文本输入模式，逐个引导用户粘贴 |

**中断恢复流程**：
```
检测到未完成的批量任务...
上次进度：[2/5] 已完成，[1] 失败，[2] 待处理
是否从中断处继续？[Y/n]
```

---

## 常见场景处理

### 场景 1：长篇论文（20+ 页）

**处理方式**：
- 自动按 H1/H2 标题分章节
- 不减少细节，维持详尽度
- 将摘要放在开头，便于快速浏览
- 提供"可跳过章节"建议（如冗余的相关工作）

### 场景 2：多篇论文比较

**处理方式**：
- 分别生成各论文摘要
- 在末尾添加"比较分析"章节，对比：
  - 核心创新点差异
  - 性能指标对标
  - 方法论优劣
  - 适用场景

### 场景 3：表格/图表密集

**处理方式**：
- 自动从表格提取数值信息
- 转换为 Markdown 表格（保留原始表格）
- 在表格下方添加"表格要点总结"

### 场景 4：数学公式

**处理方式**：
- **必须保留原论文中的 LaTeX 公式**，使用标准 LaTeX 数学模式
- 内联公式使用 `$...$` 包裹：`$L = -\sum p(y) \log q(y)$`
- 独立公式使用 `$$...$$` 或单独行 `$$` 包裹
- 保留论文中的关键方程编号（如 Eq. (3)、式 (5)）
- 如果原论文没有提供 LaTeX，从 MinerU 提取结果中还原公式
- 对于复杂的多行公式，使用 `\begin{aligned}` 等环境
- **不要用自然语言描述替代公式**，公式是科学论文的核心内容
- 在公式后添加简短的中文说明（符号含义、物理意义）

**示例**：
```markdown
#### 控制方程

Darcy 定律的二维形式：

$$q_x = -k\frac{\partial \phi}{\partial x}, \quad q_y = -k\frac{\partial \phi}{\partial y}$$

其中 $q_x$、$q_y$ 为达西通量分量，$k$ 为渗透系数，$\phi$ 为水头。

连续性方程：

$$\frac{\partial q_x}{\partial x} + \frac{\partial q_y}{\partial y} = 0$$

#### 损失函数

交叉熵损失函数：

$$L = -\sum_{i} p(y_i) \log q(y_i)$$

其中 $p$ 为真实分布，$q$ 为模型预测。该损失函数在分类任务中广泛使用，相比 MSE 损失具有更快的收敛速度。
```

### 场景 5：批量文件夹处理

**处理方式**：
- 进入批量处理模式（§批量文件夹处理模式），扫描文件夹中所有支持的论文文件
- 按文件名字母顺序依次处理，每篇论文独立生成完整总结
- 处理完成后生成批量索引文件（`_batch_index_YYYY-MM-DD.md`），包含跨论文主题分析
- 默认跳过已有同名 `.md` 总结文件的论文（使用 `--force` 强制重新处理）
- 支持 `--recursive` 递归扫描子文件夹
- 单个文件失败不阻塞其余文件，失败列表记录在索引文件中

**适用子场景**：

| 子场景 | 处理参数 | 说明 |
|--------|---------|------|
| 少量论文（≤5 篇） | 默认连续处理 | 无需暂停确认 |
| 中等批量（6-15 篇） | 每 5 篇暂停确认 | 可检查质量后继续 |
| 大批量（>15 篇） | 每 10 篇暂停，建议分批 | 避免单次处理过长 |
| 递归扫描 | `--recursive` 参数 | 按子文件夹组织输出 |
| 补处理失败项 | `--retry-failed` 参数 | 仅重新处理上次失败的项 |
| 中断恢复 | 自动检测 `_batch_progress.json` | 从中断处继续 |

---

## 故障排查

### 问题：MinerU 提取失败

**症状**："无法识别上传文件"

**解决**：
1. 检查文件格式（支持 PDF、Word .docx、PNG/JPG）
2. 检查文件大小（建议 < 50 MB）
3. 若文件是扫描件，确认清晰度足够
4. 降级方案：手动粘贴论文文本

---

### 问题：输出中文字符乱码

**症状**：输出中文显示为 "？" 或方块

**解决**：
1. 检查 Obsidian 文件编码（应为 UTF-8）
2. 在 Obsidian 设置中确认语言为中文
3. 在文件头添加 BOM 标记（重新导出）

---

### 问题：Obsidian wiki-link 无法识别

**症状**：`[[论文名]]` 没有自动链接

**解决**：
1. 确认 Obsidian 中该笔记存在（路径匹配）
2. 在 Obsidian 设置中启用"自动关联面板"
3. 手动在相关笔记中补充 backlink

---

### 问题：批量处理中断或部分失败

**症状**：批量处理中途停止，或部分论文处理失败

**解决**：
1. 检查 `_batch_progress.json` 了解进度
2. 重新运行 `/summarize-paper` 并指定同一文件夹，自动检测 `_batch_progress.json` 并从中断处继续
3. 查看索引文件中的失败列表，了解具体错误原因
4. 修复问题文件后，使用 `--retry-failed` 仅重新处理失败项

---

### 问题：文件夹中有非论文文件被误扫

**症状**：扫描结果中包含非学术论文的文件（如书籍、幻灯片、表格等）

**解决**：
1. 在批量处理前，将论文文件移到单独的子文件夹
2. 或手动从确认列表中排除非论文文件
3. 建议保持论文文件夹的整洁性，避免混合文件类型

---

## 参考文献与资源

- **FOCUS 方法**：Lin, Z. (2025). FOCUS: An AI-assisted reading workflow for information overload. _Nature Biotechnology_, 43, 2070–2075.
- **Obsidian wiki-link 语法**：https://help.obsidian.md/Linking-notes-and-files/Internal-links
- **Claude Skill 构建指南**：Anthropic Complete Guide to Building Skills for Claude (2026)
- **Claude Code 文档**：https://docs.anthropic.com/en/docs/claude-code
