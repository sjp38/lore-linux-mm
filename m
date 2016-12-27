Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 099D36B0253
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u5so348750530pgi.7
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:39 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e1si44820309pfb.241.2016.12.26.17.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 01/29] x86/cpufeature: Add 5-level paging detecton
Date: Tue, 27 Dec 2016 04:53:45 +0300
Message-Id: <20161227015413.187403-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Look for 'la57' in /proc/cpuinfo to see if your machine supports 5-level
paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/cpufeatures.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index eafee3161d1c..f2f7dbfe3cb8 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -288,7 +288,8 @@
 #define X86_FEATURE_AVX512VBMI  (16*32+ 1) /* AVX512 Vector Bit Manipulation instructions*/
 #define X86_FEATURE_PKU		(16*32+ 3) /* Protection Keys for Userspace */
 #define X86_FEATURE_OSPKE	(16*32+ 4) /* OS Protection Keys Enable */
-#define X86_FEATURE_RDPID	(16*32+ 22) /* RDPID instruction */
+#define X86_FEATURE_LA57	(16*32+16) /* 5-level page tables */
+#define X86_FEATURE_RDPID	(16*32+22) /* RDPID instruction */
 
 /* AMD-defined CPU features, CPUID level 0x80000007 (ebx), word 17 */
 #define X86_FEATURE_OVERFLOW_RECOV (17*32+0) /* MCA overflow recovery support */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
