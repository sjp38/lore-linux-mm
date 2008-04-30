Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <linux-mm@kvack.org>; Tue, 29 Apr 2008 20:14:04 -0700
Date: Tue, 29 Apr 2008 20:14:04 -0700 (PDT)
From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] docbook: fix vmalloc missing parameter notation
Message-ID: <Pine.LNX.4.64.0804292013110.18219@shark.he.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Fix vmalloc kernel-doc warning:

Warning(linux-2.6.25-git14//mm/vmalloc.c:555): No description found for parameter 'caller'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/vmalloc.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-2.6.25-git14.orig/mm/vmalloc.c
+++ linux-2.6.25-git14/mm/vmalloc.c
@@ -545,6 +545,7 @@ void *__vmalloc_area(struct vm_struct *a
  *	@gfp_mask:	flags for the page level allocator
  *	@prot:		protection mask for the allocated pages
  *	@node:		node to use for allocation or -1
+ *	@caller:	caller's return address
  *
  *	Allocate enough pages to cover @size from the page level
  *	allocator with @gfp_mask flags.  Map them into contiguous

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
