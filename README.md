# Academic Paper Summary Skill for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-blue)](https://docs.anthropic.com/en/docs/claude-code)

> 使用 FOCUS 方法对学术论文进行严谨、细节保留的总结。支持 PDF 自动提取、LaTeX 公式保留、Obsidian 一键导入、Wiki 知识图谱集成。

A Claude Code skill that transforms academic papers into detailed, structured summaries using the **FOCUS method** (Feature-Oriented Comprehension Under Scrutiny). Preserves every quantitative metric, method name, and key formula — unlike summary-only approaches.

---

## 🎯 Core Features

| Feature | Description |
|---------|-------------|
| **FOCUS Two-Phase Pipeline** | Phase A: detailed extraction (claims, metrics, formulas, quotes) → Phase B: structured cleanup with overviews |
| **MinerU PDF Extraction** | Auto-extract full-text Markdown from PDF/Word/Images via `mineru-open-api extract` |
| **LaTeX Formula Preservation** | All key equations preserved in `$...$` and `$$...$$` format — not replaced with natural language |
| **Obsidian Auto-Save** | Auto-detects current vault directory, saves directly to your working folder — zero clicks |
| **Claude-Obsidian Wiki Integration** | Auto-extracts entities & concepts, creates cross-referenced wiki pages, updates index/log/hot cache |
| **Chinese-Optimized Output** | All instructions, section headers, and explanations in Chinese; preserves English technical terms |
| **Reproducibility Checklist** | Auto-generated checklist of dataset, metrics, hardware, hyperparams mentioned in the paper |
| **Multi-Modal Input** | Accept PDF, Word, images, URLs, or pasted text |
| **Batch Folder Processing** | Scan a folder, sequentially summarize all papers, generate batch index with cross-paper analysis |
| **Figure & Table Extraction** | Auto-extract figures/tables as PNG, embed in notes with `![[figure.png]]` for Obsidian preview |
| **Textbook/Book Chapter Mode** | Auto-detect books, split by chapter, summarize each chapter, generate book index, wiki-ingest chapter-by-chapter |

---

## 📦 Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- (Optional) [MinerU Open API](https://mineru.net/) for PDF extraction — `pip install mineru-open-api`
- (Optional) [Claude-Obsidian](https://github.com/AgriciDaniel/claude-obsidian) for wiki integration

### Method 1: Subagent (Recommended)

```bash
# 1. Create agents directory
mkdir -p ~/.claude/agents

# 2. Download the skill
curl -o ~/.claude/agents/academic-paper-summary.md \
  https://raw.githubusercontent.com/luogyong/academic-paper-summary-skill/main/SKILL.md

# 3. (Optional) Also install as slash command
mkdir -p ~/.claude/commands
cat > ~/.claude/commands/summarize-paper.md <<'EOF'
Use the academic-paper-summary agent to process this request.

$ARGUMENTS
EOF
```

### Method 2: Git Clone

```bash
# Clone and copy
git clone https://github.com/luogyong/academic-paper-summary-skill.git
cp academic-paper-summary-skill/SKILL.md ~/.claude/agents/academic-paper-summary.md
```

### Method 3: Manual

1. Download [SKILL.md](SKILL.md)
2. Save to `~/.claude/agents/academic-paper-summary.md`
3. Restart Claude Code

---

## 🚀 Usage

### Trigger Keywords

In Claude Code, any of these will activate the skill:

```
/summarize-paper
总结论文
论文总结
学术论文分析
提取论文核心内容
详细论文摘要
使用FOCUS方法分析这篇论文
```

> **Tip**: `/summarize-paper` automatically detects folders and multiple files — just provide a folder path or upload multiple files to enter batch mode.

### Input Methods

**Option 1: Upload PDF (with MinerU)**
```
/summarize-paper
@paper.pdf
```

**Option 2: Paste Text**
```
帮我总结这篇论文：
[Paste the full paper text here]
```

**Option 3: Provide URL**
```
/summarize-paper
https://arxiv.org/pdf/1706.03762.pdf
```

### Batch Folder Processing (NEW)

`/summarize-paper` automatically detects when you provide a folder path or multiple files, and switches to batch mode:

```bash
# Provide a folder path → auto batch mode
/summarize-paper ~/Downloads/papers/

# With recursive scanning (includes subfolders)
/summarize-paper ~/Downloads/papers/ --recursive

# Skip already-summarized papers
/summarize-paper ~/Downloads/papers/ --skip-existing

# Retry previously failed papers only
/summarize-paper ~/Downloads/papers/ --retry-failed

# Upload multiple files at once → auto batch mode
/summarize-paper
@paper1.pdf @paper2.pdf @paper3.pdf
```

The batch mode will:
1. Scan the folder for all supported files (PDF, DOCX, images)
2. Extract text from each via MinerU (with per-file error tolerance)
3. Run FOCUS analysis on each paper sequentially
4. Generate individual summaries + a batch index file (`_batch_index_YYYY-MM-DD.md`)
5. Include cross-paper thematic analysis in the index

### Quick Start Example

```bash
# Navigate to your Obsidian vault
cd ~/Obsidian/MyVault/wiki/sources/

# Start Claude Code
claude

# Inside Claude Code:
/summarize-paper
@Attention_Is_All_You_Need.pdf
```

The skill will:
1. Extract text via MinerU
2. Run FOCUS Phase A (detailed extraction)
3. Run FOCUS Phase B (structured cleanup)
4. Generate Obsidian-formatted Markdown with LaTeX formulas
5. Auto-save to `wiki/sources/`
6. If wiki is configured: extract entities/concepts, cross-reference, update index

### Batch Quick Start

```bash
# 1. Navigate to your papers folder (or just provide the path)
cd ~/Downloads/papers/

# 2. Start Claude Code and run — auto-detects folder
claude
/summarize-paper ./

# 3. Watch progress as each paper is processed
# 4. Open _batch_index_YYYY-MM-DD.md for the overview
```

### Textbook Quick Start

```bash
# 1. Process a textbook — auto-detected as book by length + chapter structure
/summarize-paper ~/Books/machine-learning-intro.pdf

# The skill will:
# 1. Auto-detect it's a textbook (length + chapter headings)
# 2. Display the chapter structure and ask for confirmation
# 3. Split by chapter, process each independently
# 4. Generate per-chapter notes + a book index with reading routes

# Process only specific chapters
/summarize-paper ~/Books/ml-intro.pdf --chapters 3-8

# Process chapters 1, 3, and 5-8
/summarize-paper ~/Books/ml-intro.pdf --chapters 1,3,5-8
```

### Figure Extraction

Figures and tables are automatically extracted during MinerU processing and stored alongside the original PDF for future reuse:

```bash
# Standard usage — figures auto-extracted when MinerU is available
/summarize-paper ~/papers/transformer.pdf

# Output structure (co-located with the original PDF):
# ~/papers/
# ├── transformer.pdf                    # Original PDF (untouched)
# └── transformer_mineru/                # MinerU extraction output (kept for reuse)
#     ├── transformer.md                 # Full paper text with image references
#     └── images/
#         ├── fig_001.png                # Model architecture diagram
#         ├── fig_002.png                # Results comparison chart
#         └── fig_003.png                # Attention visualization
#
# Generated summary:
# transformer_summary.md  (with inline figures + appendix)
```

Figures appear in two places in the summary:
1. **Inline** — embedded right below the relevant paragraph (e.g., method diagram after the methods section)
2. **Appendix** — all figures listed at the end with full descriptions for reference

In Obsidian, extracted figures render inline in reading mode. If MinerU cannot extract figures, a `[图表未提取]` marker is placed instead.

---

## 📊 Output Structure

```markdown
---
title: "Paper Title"
authors: [Author 1, Author 2]
publication: "Journal Name Year"
year: 2026
url: "https://doi.org/..."
tags: [key, words, here]
created: 2026-06-05
updated: 2026-06-05
related_papers:
  - "[[Related Paper 1]]"
  - "[[Related Paper 2]]"
---

# 论文总结：Paper Title

## 概述
3-6 sentence overview with key metrics...

---

## 1. 贡献与关键发现
Detailed contributions with quantitative evidence...

## 2. 方法
Methods with LaTeX formulas:
$$L = -\sum p(y) \log q(y)$$

## 3. 实验结果
Results tables and comparisons...

## 4. 消融研究
Ablation study details...

## 5. 数据集与实现细节
Training data, hyperparams, hardware...

## 6. 局限性
Author-stated + inferred limitations...

## 7. 可复现性清单
Checklist format...

## 8. 高价值原文摘录
Key quotes with source locations...

## 9. 我的笔记与关联
Wiki-linked notes, concepts, and further reading...

## 10. 图表索引
Extracted figures/tables with embedded image links:

| Figure | Title | Image |
|--------|-------|-------|
| Fig 1 | Model Architecture | ![[figures/fig_01.png]] |

## 质量控制报告
Completeness verification checklist...
```

### Formula Handling

Formulas are preserved in LaTeX format, NOT replaced with natural language:

```markdown
Darcy's Law in 2D:
$$q_x = -k\frac{\partial \phi}{\partial x}, \quad q_y = -k\frac{\partial \phi}{\partial y}$$

The cross-entropy loss:
$$L = -\sum_{i} p(y_i) \log q(y_i)$$
where $p$ is the true distribution and $q$ is the model prediction.
```

---

## 🔗 Integration

### Obsidian Vault Auto-Detection

The skill automatically detects your Obsidian vault by:

1. **Current directory lookup** — walks up from `pwd` to find `.obsidian/`
2. **Memory lookup** — reads saved vault paths from `~/.claude/projects/*/memory/`
3. **Common locations** — checks `~/Obsidian/`, `~/Documents/Obsidian/`, `~/OneDrive/Obsidian/`

If detected, saves directly to your current folder — **zero clicks**.

---

### Claude-Obsidian Wiki Integration

When [claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) wiki is configured, the skill goes beyond simple file saving — it performs a **full knowledge graph ingestion**, turning your paper summary into a deeply connected wiki node.

#### What Happens During Wiki-Ingest

```
Paper Summary Generated
  ↓
┌─ 1. Save paper page to wiki/sources/{paper}.md
│      (enhanced frontmatter with entities, concepts, related_papers)
│
├─ 2. ENTITY EXTRACTION
│      Extract authors, institutions, methods, software, datasets
│      → Create or update wiki/entities/ pages
│      Example: wiki/entities/O.D.L.-Strack.md
│        wiki/entities/Analytic-Element-Method.md
│        wiki/entities/MODFLOW.md
│
├─ 3. CONCEPT EXTRACTION
│      Extract core technical concepts and theoretical frameworks
│      → Create or update wiki/concepts/ pages
│      Example: wiki/concepts/Complex-Potential-Theory.md
│        wiki/concepts/Groundwater-Flow-Modeling.md
│        wiki/concepts/Superposition-Principle.md
│
├─ 4. CROSS-REFERENCING
│      → [[wiki-link]] bidirectional links between all pages
│      → Contradiction detection: if new claims conflict with
│        existing wiki pages, add > [!contradiction] callouts
│
├─ 5. UPDATE wiki/index.md
│      Append entries for new papers, concepts, and entities
│
├─ 6. UPDATE wiki/hot.md
│      Save current context for fast future session loading
│
└─ 7. LOG to wiki/log.md
       Record: paper title, pages created/updated, timestamp
```

#### Entity Pages (Auto-Created)

For each paper, the skill creates **stub pages** for every entity mentioned:

| Entity Type | Examples | Wiki Path |
|-------------|---------|-----------|
| **Authors** | Strack, O.D.L.; Vaswani, A. | `wiki/entities/O.D.L.-Strack.md` |
| **Institutions** | Univ. of Minnesota; Google Brain | `wiki/entities/University-of-Minnesota.md` |
| **Methods/Models** | AEM; Transformer; BERT | `wiki/entities/Analytic-Element-Method.md` |
| **Software/Tools** | MODFLOW; Python; TensorFlow | `wiki/entities/MODFLOW.md` |
| **Datasets** | CASP14; ImageNet-21K; WMT 2014 | `wiki/entities/CASP14.md` |

Each entity page:
- Summarizes the entity from the paper's perspective
- Links back to the source paper via `[[paper-title]]`
- Links to related concepts
- Uses a `> [!note]` stub page marker for future expansion

#### Concept Pages (Auto-Created)

Core technical concepts extracted from the paper become concept pages:

```markdown
# Example: wiki/concepts/Complex-Potential-Theory.md
---
title: "Complex Potential Theory"
concept_type: "theoretical-framework"
source: "[[Theory and Applications of AEM 2026-06-05]]"
tags: [groundwater, aem, potential-theory]
---

## Overview
[Extracted from paper summary...]

## Papers
- [[Theory and Applications of AEM 2026-06-05]]
```

#### Index & Hot Cache Updates

```markdown
# wiki/index.md (appended entries)
### 论文总结
- [[Theory and Applications of AEM 2026-06-05]] — comprehensive review of AEM (2003)
### 概念
- [[Complex Potential Theory]] — mathematical foundation of AEM
### 实体
- [[O.D.L.-Strack]] — AEM pioneer, Univ. of Minnesota

# wiki/hot.md (context snapshot for next session)
## 2026-06-05 论文总结 | Theory and Applications of AEM
- 论文: [[Theory and Applications of AEM 2026-06-05]]
- 核心概念: [[Analytic Element Method]], [[Complex Potential Theory]], [[Groundwater Flow]]
- 关键实体: [[O.D.L.-Strack]], [[University of Minnesota]]
- 新建页面: 8 pages
```

#### Contradiction Detection

If the paper's claims conflict with existing wiki knowledge:

```markdown
> [!contradiction] Conflict with [[Existing Page]]
> [[Theory and Applications of AEM]] claims AEM solves 3D problems.
> [[Numerical Methods for Groundwater]] says AEM is limited to 2D.
> Needs resolution.
```

#### Wiki-Ingest vs Plain Save

| | Plain Save | Wiki-Ingest |
|---|-----------|-------------|
| File saved | ✅ | ✅ |
| Entity pages | ❌ | ✅ Auto-created |
| Concept pages | ❌ | ✅ Auto-created |
| Cross-references | ❌ | ✅ Bidirectional `[[]]` |
| Index update | ❌ | ✅ `wiki/index.md` |
| Hot cache | ❌ | ✅ `wiki/hot.md` |
| Activity log | ❌ | ✅ `wiki/log.md` |
| Contradiction check | ❌ | ✅ |
| Setup required | None | `/wiki` once |

---

### MinerU PDF Extraction

```bash
# Auto-detected and invoked when PDF files are uploaded
mineru-open-api extract "paper.pdf" -o ./_paper_output/ -f md
```

Supports: PDF, Word (.docx), PowerPoint (.pptx), images (.png/.jpg), HTML
Limits: 200MB max, 600 pages max per document

Fallback: If MinerU is not installed, prompts user to paste paper text.

---

## 🏗️ Architecture

### Single Paper Mode

```
User Input (PDF / Text / URL)
  ↓
Step 0: Environment Detection
├── 0.1 MinerU availability
├── 0.2 Obsidian vault (current / memory / common paths)
├── 0.3 Input type detection
├── 0.4 Environment summary
└── 0.5 Claude-Obsidian Wiki availability
  ↓
Step 1: FOCUS Phase A — Detailed Extraction
├── Section segmentation
├── Claim / metric / formula / comparison extraction
└── Source location annotation
  ↓
Step 2: FOCUS Phase B — Cleanup & Structuring
├── Remove citation markers
├── Reorganize by theme (Contributions → Methods → Results → Ablation → Limitations)
├── Add per-section overviews (3-6 sentences)
├── LaTeX formula formatting
└── Quality self-check
  ↓
Step 3: Obsidian Formatting
├── YAML frontmatter
├── [[wiki-link]] conversion
└── Backlink hints
  ↓
Step 4: Save & Wiki-ify
├── Wiki configured → Full wiki ingest (entities, concepts, index, hot, log)
└── Wiki not configured → Plain Markdown save
```

### Batch Folder Mode (NEW)

```
User provides folder path (or multiple files)
  ↓
Step B0: File Discovery
├── Scan folder for *.pdf, *.docx, *.pptx, *.png, *.jpg
├── Check for existing summaries (skip/overwrite)
└── Display file list, ask for confirmation
  ↓
Step B1: Batch MinerU Extraction
├── Extract each file → _batch_output/{filename}/
├── Track success/failure per file
└── Error tolerance: skip failures, continue with rest
  ↓
Step B2: Sequential FOCUS Processing
├── For each extracted file:
│   ├── FOCUS Phase A (detailed extraction)
│   ├── FOCUS Phase B (cleanup & structure)
│   ├── Save individual summary .md
│   └── Update _batch_progress.json (checkpoint)
├── Progress display: [N/M] with status
└── Interrupt-resume support
  ↓
Step B3: Generate Batch Index
├── _batch_index_YYYY-MM-DD.md
├── Processing summary (total/succeeded/failed)
├── Paper list table with links
└── Cross-paper thematic analysis
  ↓
Step B4: Wiki-ify & Final Confirmation
├── Batch wiki ingest (entities, concepts, index)
├── Dedup merged entities/concepts across papers
└── Final summary display
```

### Textbook/Book Chapter Mode (NEW)

```
User provides a book/textbook PDF
  ↓
Step C0: Document Type Confirmation
├── Length check (>50 pages, >30K words)
├── Structure detection (第X章 / Chapter N / Part N patterns)
├── Content analysis (preface, exercises, bibliography — not abstract/experiments)
└── Display chapter list → ask user to confirm or select range
  ↓
Step C1: Chapter Splitting
├── MinerU extract full book → Markdown
├── Split by chapter H1 headings
├── Record per-chapter metadata (title, page count, word count)
└── Create output directory structure (chapters/ + figures/)
  ↓
Step C2: Per-Chapter FOCUS Processing (sequential)
├── For each chapter:
│   ├── FOCUS Phase A (concepts, formulas, examples, figures)
│   ├── FOCUS Phase B (structured output — textbook-adapted format)
│   ├── Save individual chapter .md
│   └── Update _book_progress.json (checkpoint)
├── Progress display: [N/M] with status
└── Interrupt-resume support
  ↓
Step C3: Generate Book Index
├── {书名}_INDEX_{date}.md
├── Book metadata (authors, publisher, year, pages)
├── Chapter index table with links
├── Cross-chapter thematic analysis + knowledge progression map
└── Recommended reading routes (speed / standard / topical)
  ↓
Step C4: Wiki-ify
├── Book index → wiki/sources/
├── Per-chapter → wiki/sources/{book}/chapters/
├── Entity page for the book itself
├── Concepts aggregated across chapters
└── Update wiki/index.md and wiki/hot.md
```

---

## 📁 File Structure

```
academic-paper-summary-skill/
├── SKILL.md          # The skill definition (Claude Code agent format)
├── README.md         # This file
└── LICENSE           # MIT License
```

After installation:

```
~/.claude/
├── agents/
│   └── academic-paper-summary.md    # Subagent (loaded automatically)
└── commands/
    └── summarize-paper.md           # Slash command (optional)
```

---

## 🛠️ Configuration

### MinerU

```bash
# Install MinerU CLI
pip install mineru-open-api

# Verify
mineru-open-api --version
```

If MinerU is unavailable, the skill gracefully falls back to text input mode.

### Claude-Obsidian Wiki

```bash
# In Claude Code, run:
/wiki
```

This scaffolds the wiki vault structure. Once configured, paper summaries will be automatically wiki-fied.

---

## ❓ FAQ

**Q: Does this replace reading the paper?**
A: No. It captures all key details for literature review and reference — you should still read the full paper for deep understanding.

**Q: What if I don't use Obsidian?**
A: The skill works standalone. Choose "display Markdown" when saving, and use with any Markdown editor.

**Q: What if my paper has complex mathematical notation?**
A: The skill preserves LaTeX formulas whenever possible. For papers with heavy equation content, formulas are kept in `$$...$$` blocks.

**Q: Can I summarize multiple papers at once?**
A: Yes! Just provide a folder path to `/summarize-paper` (e.g., `/summarize-paper ~/papers/`) and it automatically switches to batch mode. Each paper gets a full individual summary, plus a cross-paper analysis index. You can also provide multiple files at once.

**Q: Does it work with Chinese papers?**
A: Yes. Language auto-detection works for Chinese and English. Output is always in Chinese.

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.2.0 | 2026-06-05 | Claude-Obsidian wiki integration (entity/concept extraction, cross-referencing, index updates) |
| 0.1.1 | 2026-06-04 | MinerU CLI support, LaTeX formula preservation, vault auto-detection enhancements |
| 0.1.0 | 2026-06-03 | Initial release — FOCUS pipeline, MinerU support, Obsidian save |

---

## 📝 License

MIT © 2026 [luogyong](https://github.com/luogyong)

---

## 🙏 Acknowledgments

- **FOCUS Method**: Lin, Z. (2025). FOCUS: An AI-assisted reading workflow for information overload. *Nature Biotechnology*, 43, 2070–2075.
- **[MinerU](https://mineru.net/)**: PDF content extraction engine
- **[Claude-Obsidian](https://github.com/AgriciDaniel/claude-obsidian)**: Self-organizing AI second brain for Obsidian + Claude Code
- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)**: Anthropic's CLI for Claude

---

## ⭐ Star This Repo

If this skill helps your research workflow, consider giving it a star ⭐ — it helps others discover it too!
