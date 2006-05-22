Date: Mon, 22 May 2006 10:53:27 +0100
Subject: [PATCH 2/2] x86 add zone alignment qualifier
Message-ID: <20060522095327.GA6978@shadowen.org>
References: <exportbomb.1148291574@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

x86 add zone alignment qualifier

x86 takes steps to ensure all of its zones are aligned.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 Kconfig |    3 +++
 1 files changed, 3 insertions(+)
diff -upN reference/arch/i386/Kconfig current/arch/i386/Kconfig
--- reference/arch/i386/Kconfig
+++ current/arch/i386/Kconfig
@@ -577,6 +577,9 @@ config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 	depends on ARCH_SPARSEMEM_ENABLE
 
+config ARCH_ALIGNED_ZONE_BOUNDARIES
+	def_bool y
+
 source "mm/Kconfig"
 
 config HAVE_ARCH_EARLY_PFN_TO_NID

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
