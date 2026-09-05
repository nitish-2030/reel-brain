Reel Brain — Progress Log (Problems & Solutions)
Problem 1: Gemini sirf Instagram URL dekh raha tha, actual video content nahi

Symptom: Gemini response — "I cannot access external websites or real-time content"
Root Cause: Workflow Gemini ko sirf reel ka text URL bhej raha tha, video/audio file nahi.
Solution: yt-dlp tool install karke, Telegram se aaye URL ko locally download karna, phir video file ko Gemini ko bhejna.

Problem 2: n8n mein "Execute Command" node missing tha

Symptom: Node search mein "Execute Command" dikh hi nahi raha tha.
Root Cause: n8n version 2.0+ mein ye node security reasons se default disabled hota hai.
Solution: Environment variable set kiya:

$env:NODES_EXCLUDE="[]"

Iske baad node dikhne laga.

Problem 3: Telegram data structure galat assume kiya

Symptom: {{ $json.message.text }} expression empty resolve ho raha tha → '' is not a valid URL error.
Root Cause: Telegram Trigger channel post pe fire ho raha tha, normal message pe nahi — sahi path channel_post.text tha, message.text nahi.
Solution: Expression fix kiya:

{{ $json.channel_post.text }}
Problem 4: Downloaded video file ko Gemini tak "read" nahi kar pa rahe the

Symptom: Read/Write Files from Disk node ne "Access to the file is not allowed" error diya.
Root Cause: n8n by default sirf apne internal .n8n-files folder tak file access allow karta hai, baahar ke kisi bhi disk path (jaise D:\reel_temp) ko block karta hai.
Solution: Environment variable set kiya:

$env:N8N_RESTRICT_FILE_ACCESS_TO="D:\reel_temp"
Problem 5: Dynamic filename expression resolve nahi ho raha tha (rendering issue)

Symptom: Preview mein sahi filename dikhta tha, lekin actual test run mein raw {{ }} text hi error mein aata tha.
Root Cause: Complex multiline regex expression seedhe "File(s) Selector" field mein likhne se n8n ka UI usse properly commit/save nahi kar pa raha tha.
Solution: Beech mein ek Code node add kiya jo stdout se filename regex se nikaal ke ek clean filePath variable banata hai — Read File node ko sirf simple {{ $json.filePath }} expression dena pada, jo reliably kaam kiya.

Problem 6: n8n ke built-in Gemini node mein video/file attach karne ka option nahi tha

Symptom: "Message a Model" operation mein sirf plain text Prompt field tha, video reference dene ka koi UI option nahi.
Root Cause: Is n8n Gemini node version mein sirf text-only messaging support hai.
Solution: HTTP Request node use karke seedha Google Gemini API (generateContent endpoint) ko call kiya, jisme JSON body mein fileData (fileUri + mimeType) aur text prompt dono manually bheje.

Final Working Pipeline
Telegram (reel forward)
   → Execute Command (yt-dlp download)
   → Code (filename extract from stdout)
   → Read File from Disk (binary data)
   → Upload Media File (Gemini File API)
   → HTTP Request (Gemini generateContent — actual video analysis)
   → Code (parse Gemini's JSON response)
   → Notion (save Title, Summary, Tags, Link, Date, Type)

Result: Reel forward karne pe, real video-based summary + tags automatically Notion mein save ho rahe hain — koi manual step nahi.
