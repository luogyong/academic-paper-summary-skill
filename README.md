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
  https://raw.githubusercontent.com/gyluo/academic-paper-summary-skill/main/SKILL.md

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
git clone https://github.com/gyluo/academic-paper-summary-skill.git
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

### Claude-Obsidian Wiki Integration

When [claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) wiki is configured:

```
Paper Summary Generated
  ↓
Save to wiki/sources/{paper}.md (enhanced frontmatter)
  ↓
Extract entities → create/update wiki/entities/ pages
  ↓
Extract concepts → create/update wiki/concepts/ pages
  ↓
Cross-reference with [[wiki-link]] bidirectional links
  ↓
Update wiki/index.md, wiki/hot.md, wiki/log.md
```

This turns each paper summary into a **fully connected knowledge graph node**.

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
A: Yes. The skill handles multi-paper comparison mode with cross-paper analysis.

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

MIT © 2026 [gyluo](https://github.com/gyluo)

---

## 🙏 Acknowledgments

- **FOCUS Method**: Lin, Z. (2025). FOCUS: An AI-assisted reading workflow for information overload. *Nature Biotechnology*, 43, 2070–2075.
- **[MinerU](https://mineru.net/)**: PDF content extraction engine
- **[Claude-Obsidian](https://github.com/AgriciDaniel/claude-obsidian)**: Self-organizing AI second brain for Obsidian + Claude Code
- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)**: Anthropic's CLI for Claude

---

## ⭐ Star This Repo

If this skill helps your research workflow, consider giving it a star ⭐ — it helps others discover it too!
