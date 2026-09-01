\# 🧠 Reel Brain



> \*\*A personal automation system that turns saved Instagram Reels into a searchable knowledge base.\*\*



Reel Brain helps solve a simple problem:



You find useful Instagram Reels about AI tools, automation, tutorials, ideas, or solutions — save them for later — and then forget about them.



Reel Brain turns those saved Reels into \*\*organized, summarized, searchable knowledge\*\*.



\---



\## 🚀 How It Works



The basic workflow is:



\*\*Instagram Reel → Telegram → n8n → Gemini → Notion\*\*



1\. \*\*Capture\*\*

&#x20;  Forward an Instagram Reel or useful content to a private Telegram channel.



2\. \*\*Understand\*\*

&#x20;  Local n8n picks up the content and sends the available video/audio/caption to Google Gemini.



3\. \*\*Summarize \& Tag\*\*

&#x20;  Gemini generates:



&#x20;  \* A short summary

&#x20;  \* Relevant tags

&#x20;  \* The problem or need the content addresses



4\. \*\*Store\*\*

&#x20;  n8n saves the result as a new entry in a Notion database.



5\. \*\*Recall\*\*

&#x20;  Later, search or filter Notion by keyword, tag, or date to find useful content without rewatching everything.



\---



\## 🏗️ Architecture



```text

┌─────────────────┐

│  Instagram Reel │

└────────┬────────┘

&#x20;        │ Forward

&#x20;        ▼

┌─────────────────┐

│ Telegram Inbox  │

└────────┬────────┘

&#x20;        │

&#x20;        ▼

┌─────────────────┐

│   Local n8n     │

│   Automation    │

└────────┬────────┘

&#x20;        │

&#x20;        ▼

┌─────────────────┐

│ Google Gemini   │

│ AI Processing   │

└────────┬────────┘

&#x20;        │

&#x20;        ▼

┌─────────────────┐

│      Notion     │

│ Knowledge Base  │

└─────────────────┘

&#x20;        │

&#x20;        ▼

&#x20;  Search \& Recall

```



\---



\## 🛠️ Tech Stack



| Technology            | Purpose                                                   |

| --------------------- | --------------------------------------------------------- |

| \*\*Telegram\*\*          | Personal inbox for forwarded Reels                        |

| \*\*n8n\*\*               | Local automation engine                                   |

| \*\*Google Gemini API\*\* | Video/audio/text understanding, summarization and tagging |

| \*\*Notion\*\*            | Searchable storage and knowledge base                     |

| \*\*Node.js / npm\*\*     | Runs the local n8n setup                                  |



All services are intended to be used on their free tiers for this project.



\*\*Target cost: $0\*\*



\---



\## 📋 Notion Database



Each saved piece of content is stored with information such as:



\* \*\*Title\*\*

\* \*\*Summary\*\*

\* \*\*Tags\*\*

\* \*\*Link\*\*

\* \*\*Date Saved\*\*

\* \*\*Type\*\* — Reel / Image / Other



This turns a collection of random saved Reels into structured information that can be searched later.



\---



\## 📂 Repository Structure



```text

reel-brain/

│

├── README.md

├── .gitignore

│

├── docs/

│   └── Project documentation and context

│

├── workflows/

│   └── n8n workflow exports

│

├── notion/

│   └── Notion database/schema notes

│

└── progress/

&#x20;   └── Project progress logs

```



\---



\## 📊 Current Status



\### Setup Progress



\* \[x] GitHub repository created

\* \[x] Local Git repository initialized

\* \[x] GitHub remote connected

\* \[x] Initial repository structure created

\* \[x] `.gitignore` configured

\* \[ ] Update n8n

\* \[ ] Telegram Bot + private channel

\* \[ ] Notion database

\* \[ ] Gemini API setup

\* \[ ] Connect Telegram + Gemini + Notion in n8n

\* \[ ] Build complete automation workflow

\* \[ ] Daily usage setup

\* \[ ] Verify \& Expand feature \*(optional)\*



> \*\*Current phase:\*\* Project repository setup completed. Automation setup is next.



\---



\## 🗺️ Roadmap



\### Phase 1 — Foundation



\* Set up and verify n8n

\* Create Telegram bot and private channel

\* Create Notion database

\* Configure Gemini API



\### Phase 2 — Integration



\* Connect Telegram to n8n

\* Connect Gemini to n8n

\* Connect Notion to n8n

\* Test each integration



\### Phase 3 — Automation



\* Detect forwarded content

\* Process available Reel content

\* Generate summary and tags

\* Save structured information to Notion

\* Handle cases where only caption/link information is available



\### Phase 4 — Daily Usage



\* Make Reel capture fast and effortless

\* Keep n8n running reliably

\* Create useful Notion views

\* Develop a regular review habit



\### Phase 5 — Optional Expansion



Add a \*\*"Verify This"\*\* feature that can analyze a saved Reel's claims and, where supported, produce a verified step-by-step solution.



\---



\## 🔐 Security



\*\*Never commit secrets to this repository.\*\*



API keys, bot tokens, Notion integration tokens, credentials, and other sensitive configuration should remain outside Git.



The repository's `.gitignore` is configured to help prevent common secret/configuration files from being committed.



\---



\## 💡 Why Reel Brain?



The goal isn't simply to save more content.



The goal is to make saved content \*\*useful later\*\*.



Instead of:



```text

"I remember seeing a Reel about this..."

```



The goal is:



```text

"I need a solution for X."

&#x20;       ↓

Search Notion

&#x20;       ↓

Find relevant Reel

&#x20;       ↓

Read the summary

&#x20;       ↓

Use the useful information

```



\---



\## 📌 Project Philosophy



\*\*Capture → Understand → Organize → Recall\*\*



Save less mentally.

Remember more automatically.



\---



\## 📄 Documentation



Additional project documentation and setup information will be maintained inside the `docs/` directory.



\---



\## ⚠️ Project Status



Reel Brain is a personal automation project currently under development.



The repository will be updated incrementally as each component is built and tested.



