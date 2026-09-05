# 🧠 Reel Brain — Progress Log

> **Purpose:** Instagram Reel → Video Download → Gemini Analysis → Notion
> **Status:** ✅ Working
> **Last Updated:** September 2026

---

## 📌 Project Overview

**Reel Brain** ek automation workflow hai jisme Telegram par reel forward karne ke baad:

1. Reel URL receive hota hai
2. Reel video automatically download hoti hai
3. Video Gemini ko analysis ke liye bheji jaati hai
4. Gemini actual **video content** analyze karta hai
5. Summary, title, tags etc. extract hote hain
6. Final data automatically Notion mein save hota hai

---

# 🐛 Problems & Solutions

## Problem 1 — Gemini Sirf Instagram URL Dekh Raha Tha

### ❌ Symptom

Gemini response:

> `"I cannot access external websites or real-time content"`

### 🔍 Root Cause

Workflow Gemini ko sirf **Instagram Reel ka URL** bhej raha tha.

Gemini ke paas actual:

* 🎥 Video
* 🔊 Audio
* 🎬 Visual content

nahi tha.

Isliye Gemini reel ko directly dekh/analyze nahi kar pa raha tha.

### ✅ Solution

`yt-dlp` use karke Telegram se received Reel URL ko **locally download** kiya.

**Flow:**

```text
Instagram URL
      ↓
    yt-dlp
      ↓
 Local Video File
      ↓
    Gemini
```

---

## Problem 2 — n8n Mein `Execute Command` Node Missing Tha

### ❌ Symptom

n8n ke node search mein:

```text
Execute Command
```

dikh hi nahi raha tha.

### 🔍 Root Cause

n8n **2.0+** mein `Execute Command` node security reasons ki wajah se default disabled ho sakta hai.

### ✅ Solution

Environment variable set kiya:

```powershell
$env:NODES_EXCLUDE="[]"
```

Iske baad n8n restart karne par `Execute Command` node available ho gaya.

---

## Problem 3 — Telegram Data Structure Galat Assume Kiya

### ❌ Symptom

Ye expression empty resolve ho raha tha:

```javascript
{{ $json.message.text }}
```

Result:

```text
'' is not a valid URL
```

### 🔍 Root Cause

Telegram Trigger **normal message** par nahi, balki **channel post** par fire ho raha tha.

Isliye data structure:

```text
message.text
```

nahi tha.

Actual structure:

```text
channel_post.text
```

### ✅ Solution

Expression ko change kiya:

```javascript
{{ $json.channel_post.text }}
```

### 💡 Important

Telegram ke different event types mein JSON structure different ho sakta hai.

Always check the **actual Trigger output** before writing expressions.

---

## Problem 4 — Downloaded Video Gemini Tak Read Nahi Ho Rahi Thi

### ❌ Symptom

`Read/Write Files from Disk` node error:

```text
Access to the file is not allowed
```

### 🔍 Root Cause

n8n security restrictions ke according file access limited tha.

n8n default mein apne allowed/internal file location ke bahar ke paths ko block kar raha tha.

Example:

```text
D:\reel_temp
```

accessible nahi tha.

### ✅ Solution

Allowed file-access directory define ki:

```powershell
$env:N8N_RESTRICT_FILE_ACCESS_TO="D:\reel_temp"
```

Ab n8n ko `D:\reel_temp` ke andar files access karne ki permission mil gayi.

---

## Problem 5 — Dynamic Filename Expression Resolve Nahi Ho Raha Tha

### ❌ Symptom

n8n preview mein filename correctly show ho raha tha.

Lekin actual workflow run ke time raw expression:

```text
{{ ... }}
```

error mein aa raha tha.

### 🔍 Root Cause

Complex multiline regex expression ko directly:

```text
File(s) Selector
```

field mein use kiya ja raha tha.

n8n UI expression ko properly **commit/save/render** nahi kar pa raha tha.

### ❌ Old Approach

```text
Read File
   ↓
Complex regex expression
   ↓
File(s) Selector
```

### ✅ Solution

Beech mein ek **Code node** add kiya.

Code node:

1. `stdout` receive karta hai
2. Regex se filename extract karta hai
3. Clean `filePath` variable create karta hai

Example output:

```javascript
{
  "filePath": "D:\\reel_temp\\reel_123.mp4"
}
```

Ab Read File node mein sirf simple expression use hua:

```javascript
{{ $json.filePath }}
```

### 💡 Result

Simple expression reliably work karne laga.

---

## Problem 6 — n8n Gemini Node Mein Video Attach Karne Ka Option Nahi Tha

### ❌ Symptom

n8n ke Gemini:

```text
Message a Model
```

operation mein mainly plain-text prompt field available tha.

Actual video file/reference attach karne ka required option nahi tha.

### 🔍 Root Cause

Currently used n8n Gemini node/version mein required **video/file input workflow** directly supported nahi tha.

### ❌ Problematic Flow

```text
Video File
    ↓
Gemini Node
    ↓
❌ Video properly attach nahi ho rahi
```

### ✅ Solution

Built-in Gemini node ki jagah:

```text
HTTP Request
```

node use kiya.

Direct **Google Gemini API — `generateContent` endpoint** ko call kiya.

Request body mein:

* `fileData`
* `fileUri`
* `mimeType`
* Text prompt

manually send kiya.

### Working Concept

```text
Video File
    ↓
Gemini File API
    ↓
fileUri
    ↓
generateContent API
    ↓
Gemini Video Analysis
```

Isse Gemini ko **actual uploaded video** milne lagi, sirf Instagram URL nahi.

---

# 🚀 Final Working Pipeline

```text
┌─────────────────────┐
│ Telegram             │
│ Reel Forward         │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Execute Command      │
│ yt-dlp Download      │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Code Node            │
│ Extract Filename     │
│ Create filePath      │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Read File from Disk  │
│ Load Video Binary    │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Gemini File API      │
│ Upload Video         │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ HTTP Request         │
│ Gemini generateContent│
│ Video Analysis       │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Code Node            │
│ Parse Gemini JSON    │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Notion               │
│ Save Reel Data       │
└─────────────────────┘
```

---

# 📊 Final Output

Telegram par sirf **Reel forward** karni hai.

Workflow automatically:

| Step | Action                       | Status |
| ---- | ---------------------------- | ------ |
| 1    | Telegram se Reel URL receive | ✅      |
| 2    | Reel video download          | ✅      |
| 3    | Filename extract             | ✅      |
| 4    | Video binary read            | ✅      |
| 5    | Gemini File API upload       | ✅      |
| 6    | Actual video analysis        | ✅      |
| 7    | Gemini response parse        | ✅      |
| 8    | Notion mein data save        | ✅      |

---

# 📝 Notion Mein Save Hone Wala Data

Workflow ke final output mein automatically:

* **Title**
* **Summary**
* **Tags**
* **Reel Link**
* **Date**
* **Type**

save ho raha hai.

---

# 🎯 Final Result

> **Reel forward karo → workflow automatically video download karega → Gemini actual video analyze karega → structured information extract hogi → Notion mein save ho jayegi.**

### ✅ No Manual Step

```text
Telegram Reel
      ↓
   🤖 Automation
      ↓
🎥 Video Analysis
      ↓
🧠 Gemini
      ↓
📝 Notion
```

---

# 🔧 Important Configuration

## n8n Environment Variables

### Enable Execute Command

```powershell
$env:NODES_EXCLUDE="[]"
```

### Allow Reel Temporary Directory

```powershell
$env:N8N_RESTRICT_FILE_ACCESS_TO="D:\reel_temp"
```

---

# 🧠 Key Learnings

### 1. URL ≠ Video

Gemini ko sirf URL dene se actual reel content necessarily available nahi hota.

**Actual video upload → reliable video analysis.**

### 2. Always Inspect Trigger Output

Telegram/n8n expressions banane se pehle actual JSON structure check karna important hai.

```text
message.text
```

aur

```text
channel_post.text
```

same nahi hote.

### 3. Keep Expressions Simple

Agar n8n UI complex expression ko properly render/save nahi kar raha:

```text
Complex Expression
       ↓
    Code Node
       ↓
 Simple Variable
```

better approach hai.

### 4. Built-in Node Limitations Ke Liye API Use Kar Sakte Hain

Agar n8n ka built-in node required functionality expose nahi karta:

```text
Built-in Node
     ↓
   Limitation
     ↓
HTTP Request
     ↓
Direct API
```

zyada control deta hai.

---

# 📌 Current Status

**Reel Brain:** 🟢 **WORKING**

**Core Pipeline:**
`Telegram → yt-dlp → File → Gemini → Analysis → Notion`

**Main Problem Solved:**
Gemini ab **actual Reel video** analyze kar raha hai, sirf Instagram URL nahi.
