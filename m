Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BDC0D8D0040
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 16:27:42 -0400 (EDT)
Date: Sat, 26 Mar 2011 13:27:01 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] mm: fix memory.c incorrect kernel-doc
Message-Id: <20110326132701.f0014b20.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: akpm <akpm@linux-foundation.org>, torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix mm/memory.c incorrect kernel-doc function notation:

Warning(mm/memory.c:3718): Cannot understand  * @access_remote_vm - access another process' address space
 on line 3718 - I thought it was a doc line

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.38-git18.orig/mm/memory.c
+++ linux-2.6.38-git18/mm/memory.c
@@ -3715,7 +3715,7 @@ static int __access_remote_vm(struct tas
 }
 
 /**
- * @access_remote_vm - access another process' address space
+ * access_remote_vm - access another process' address space
  * @mm:		the mm_struct of the target address space
  * @addr:	start address to access
  * @buf:	source or destination buffer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
