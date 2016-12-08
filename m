Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7EE606B027F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:22:39 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p66so175485017pga.4
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:22:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n11si29469613plg.334.2016.12.08.08.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:22:38 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv1 27/28] x86: enable la57 support
Date: Thu,  8 Dec 2016 19:21:49 +0300
Message-Id: <20161208162150.148763-29-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Most of things are in place and we can enable support of 5-level paging.
Things that known to be broken marked as BROKEN.

Not-yet-Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index df4f1d514ab0..83a4c22111b3 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -309,6 +309,7 @@ config DEBUG_RODATA
 
 config PGTABLE_LEVELS
 	int
+	default 5 if X86_5LEVEL
 	default 4 if X86_64
 	default 3 if X86_PAE
 	default 2
@@ -1340,6 +1341,10 @@ config X86_PAE
 	  has the cost of more pagetable lookup overhead, and also
 	  consumes more pagetable space per process.
 
+config X86_5LEVEL
+	bool "Enable 5-level page tables support"
+	depends on X86_64
+
 config ARCH_PHYS_ADDR_T_64BIT
 	def_bool y
 	depends on X86_64 || X86_PAE
@@ -1698,6 +1703,7 @@ config X86_SMAP
 config X86_INTEL_MPX
 	prompt "Intel MPX (Memory Protection Extensions)"
 	def_bool n
+	depends on !X86_5LEVEL
 	depends on CPU_SUP_INTEL
 	---help---
 	  MPX provides hardware features that can be used in
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
