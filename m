Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7DA5F5F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 05:39:46 -0400 (EDT)
Subject: [PATCH] mm: move the scan_unevictable_pages sysctl to the vm table
From: Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 09 Apr 2009 11:42:13 +0200
Message-Id: <1239270133.7647.213.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "lee.schermerhorn" <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Subject: mm: move the scan_unevictable_pages sysctl to the vm table
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu Apr 09 11:38:45 CEST 2009

vm knobs should go in the vm table. Probably too late for randomize_va_space
though.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/sysctl.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -914,16 +914,6 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 #endif
-#ifdef CONFIG_UNEVICTABLE_LRU
-	{
-		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "scan_unevictable_pages",
-		.data		= &scan_unevictable_pages,
-		.maxlen		= sizeof(scan_unevictable_pages),
-		.mode		= 0644,
-		.proc_handler	= &scan_unevictable_handler,
-	},
-#endif
 #ifdef CONFIG_SLOW_WORK
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -1324,6 +1314,16 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+#ifdef CONFIG_UNEVICTABLE_LRU
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "scan_unevictable_pages",
+		.data		= &scan_unevictable_pages,
+		.maxlen		= sizeof(scan_unevictable_pages),
+		.mode		= 0644,
+		.proc_handler	= &scan_unevictable_handler,
+	},
+#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
