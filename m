Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4602D6B0276
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:52 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g1so737187728pgn.3
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:52 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d1si10338243pld.20.2016.12.26.17.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 28/29] x86: enable 5-level paging support
Date: Tue, 27 Dec 2016 04:54:12 +0300
Message-Id: <20161227015413.187403-29-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Most of things are in place and we can enable support of 5-level paging.

MPX for 5-level paging will be enabled with separate patchset.
It requires change to GCC components which has not ready yet.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 3d51256a9e61..07cc4f27ca41 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -315,6 +315,7 @@ config DEBUG_RODATA
 
 config PGTABLE_LEVELS
 	int
+	default 5 if X86_5LEVEL
 	default 4 if X86_64
 	default 3 if X86_PAE
 	default 2
@@ -1379,6 +1380,10 @@ config X86_PAE
 	  has the cost of more pagetable lookup overhead, and also
 	  consumes more pagetable space per process.
 
+config X86_5LEVEL
+	bool "Enable 5-level page tables support"
+	depends on X86_64
+
 config ARCH_PHYS_ADDR_T_64BIT
 	def_bool y
 	depends on X86_64 || X86_PAE
@@ -1737,6 +1742,7 @@ config X86_SMAP
 config X86_INTEL_MPX
 	prompt "Intel MPX (Memory Protection Extensions)"
 	def_bool n
+	depends on !X86_5LEVEL
 	depends on CPU_SUP_INTEL
 	---help---
 	  MPX provides hardware features that can be used in
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
