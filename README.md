# 📝Notion Export to GitHub Auto Sync Tool

Automatically sync your Notion-exported HTML (and .md) pages to a GitHub repository — cleaned, fixed, committed, and pushed with one click.

---

## 📦 What It Does

- 🔍 Detects the latest Notion export `.zip` from your Downloads folder(dont rename the file 😅)
- 📦 Extracts it to a temp folder
- ✂️ Cleans folder and file names by removing UUIDs
- 🧠 Fixes internal HTML links and emoji/encoding issues
- 🔄 Mirrors changes into a local GitHub repo
- 📝 Auto-commits and pushes changes to GitHub
- 🌐 Opens your GitHub repo in the browser
- 🧹 Cleans up the ZIP and temp folder after use

---

## 🛠 Requirements

| Tool | Usage |
|------|-------|
| 🪟 Windows | Batch and PowerShell based |
| 🐍 Python 3.7+ | Required to fix HTML encoding and links |
| 📦 Python packages | `ftfy`, `beautifulsoup4`, `chardet` |
| 🔧 Git | Used for auto `add`, `commit`, and `push` |
| 💻 PowerShell | Used for safe folder renaming and link cleanup |

---

## ⚙ Installation

1.  **Install Git**  
    [https://git-scm.com/downloads](https://git-scm.com/downloads)

2.  **Install Python 3.x**  
    [https://www.python.org/downloads/](https://www.python.org/downloads/)

3.  **Install required Python packages**:
    ```bash
    pip install ftfy beautifulsoup4 chardet
    ```

4.  **Clone this repository or Download as ZIP**

5.  **Edit this line** inside `notion-sync.bat` to match your local GitHub folder:
    ```bat
    set "GITHUB_DIR=C:\GitHub\Your-Repo-Name"
    ```

---

## 🚀 How to Use

1.  Export your Notion workspace (as in this case) **HTML** and place the `.zip` file in your **Downloads** folder.
![Screenshot 2025-06-26 150128](https://github.com/user-attachments/assets/2562c072-6da4-456c-8150-631669a1af6b)


2.  Run `notion-sync.bat` (double-click or run from terminal).

3.  Done! It will:
    - Extract & clean the export
    - Fix internal links and encoding
    - Push the updates to GitHub
    - Open your repo in browser
    - delete the original notion zip file and the temp files.

---

## 📁 File Structure

```bash
notion-html-sync/
├── notion-sync.bat              # Master script
├── cleanup-notion.ps1           # PowerShell rename utility
├── process_notion_html.py       # Python cleanup for HTML encoding/links
├── .gitignore                   # Ignores logs and temp files
└── README.md                    # You're reading this

```

## 💡 Optional: Prebuilt .exe Version

Want a single-file version that doesn’t require Python or setup?  
Check the `releases/` folder for a prebuilt `notion-sync.exe`.

**📦 [Download the EXE version here](#)**
