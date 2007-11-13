Date: Mon, 12 Nov 2007 19:47:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Sparsemem: Do not reserve section flags if VMEMMAP is in use
Message-ID: <Pine.LNX.4.64.0711121944400.30269@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sparsemem with virtual memmap does not need the section flags in
the page flags. Do not allocate the bits if they are not needed.

This has the potential of freeing up a lot of page flags if SPARSE
can be made to consistently use a virtual memmap.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2007-11-12 19:36:39.472347109 -0800
+++ linux-2.6/include/linux/mm.h	2007-11-12 19:37:05.197064250 -0800
@@ -378,7 +378,7 @@ static inline void set_compound_order(st
  * with space for node: | SECTION | NODE | ZONE | ... | FLAGS |
  *   no space for node: | SECTION |     ZONE    | ... | FLAGS |
  */
-#ifdef CONFIG_SPARSEMEM
+#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTIONS_WIDTH		SECTIONS_SHIFT
 #else
 #define SECTIONS_WIDTH		0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
