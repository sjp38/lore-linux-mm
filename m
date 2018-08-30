Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3164D6B5243
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:44:45 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e8-v6so4064216plt.4
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:44:45 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t10-v6si6980653pgn.667.2018.08.30.07.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:44:44 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 5/8] x86/cet/ibt: Add ENDBR to op-code-map
Date: Thu, 30 Aug 2018 07:40:06 -0700
Message-Id: <20180830144009.3314-6-yu-cheng.yu@intel.com>
In-Reply-To: <20180830144009.3314-1-yu-cheng.yu@intel.com>
References: <20180830144009.3314-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Add control transfer terminating instructions:

ENDBR64/ENDBR32:
    Mark a valid 64/32-bit control transfer endpoint.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/lib/x86-opcode-map.txt               | 13 +++++++++++--
 tools/objtool/arch/x86/lib/x86-opcode-map.txt | 13 +++++++++++--
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/arch/x86/lib/x86-opcode-map.txt b/arch/x86/lib/x86-opcode-map.txt
index c5e825d44766..fbc53481bc59 100644
--- a/arch/x86/lib/x86-opcode-map.txt
+++ b/arch/x86/lib/x86-opcode-map.txt
@@ -620,7 +620,16 @@ ea: SAVEPREVSSP (f3)
 # Skip 0xeb-0xff
 EndTable
 
-Table: 3-byte opcode 2 (0x0f 0x38)
+Table: 3-byte opcode 2 (0x0f 0x1e)
+Referrer:
+AVXcode:
+# Skip 0x00-0xf9
+fa: ENDBR64 (f3)
+fb: ENDBR32 (f3)
+#skip 0xfc-0xff
+EndTable
+
+Table: 3-byte opcode 3 (0x0f 0x38)
 Referrer: 3-byte escape 1
 AVXcode: 2
 # 0x0f 0x38 0x00-0x0f
@@ -804,7 +813,7 @@ f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v) | WRSS Pq,Qq
 f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By (F3),(v) | SHRX Gy,Ey,By (F2),(v)
 EndTable
 
-Table: 3-byte opcode 3 (0x0f 0x3a)
+Table: 3-byte opcode 4 (0x0f 0x3a)
 Referrer: 3-byte escape 2
 AVXcode: 3
 # 0x0f 0x3a 0x00-0xff
diff --git a/tools/objtool/arch/x86/lib/x86-opcode-map.txt b/tools/objtool/arch/x86/lib/x86-opcode-map.txt
index c5e825d44766..fbc53481bc59 100644
--- a/tools/objtool/arch/x86/lib/x86-opcode-map.txt
+++ b/tools/objtool/arch/x86/lib/x86-opcode-map.txt
@@ -620,7 +620,16 @@ ea: SAVEPREVSSP (f3)
 # Skip 0xeb-0xff
 EndTable
 
-Table: 3-byte opcode 2 (0x0f 0x38)
+Table: 3-byte opcode 2 (0x0f 0x1e)
+Referrer:
+AVXcode:
+# Skip 0x00-0xf9
+fa: ENDBR64 (f3)
+fb: ENDBR32 (f3)
+#skip 0xfc-0xff
+EndTable
+
+Table: 3-byte opcode 3 (0x0f 0x38)
 Referrer: 3-byte escape 1
 AVXcode: 2
 # 0x0f 0x38 0x00-0x0f
@@ -804,7 +813,7 @@ f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v) | WRSS Pq,Qq
 f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By (F3),(v) | SHRX Gy,Ey,By (F2),(v)
 EndTable
 
-Table: 3-byte opcode 3 (0x0f 0x3a)
+Table: 3-byte opcode 4 (0x0f 0x3a)
 Referrer: 3-byte escape 2
 AVXcode: 3
 # 0x0f 0x3a 0x00-0xff
-- 
2.17.1
