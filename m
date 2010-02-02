From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 02/11] readahead: bump up the default readahead size
Date: Tue, 02 Feb 2010 23:28:37 +0800
Message-ID: <20100202153316.513043033@intel.com>
References: <20100202152835.683907822@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NcKmo-0004zN-0i
	for glkm-linux-mm-2@m.gmane.org; Tue, 02 Feb 2010 16:35:30 +0100
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A54F36B009A
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 10:35:27 -0500 (EST)
Content-Disposition: inline; filename=readahead-enlarge-default-size.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Use 512kb max readahead size, and 32kb min readahead size.

The former helps io performance for common workloads.
The latter will be used in the thrashing safe context readahead.

CC: Jens Axboe <jens.axboe@oracle.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/mm.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux.orig/include/linux/mm.h	2010-01-30 17:38:49.000000000 +0800
+++ linux/include/linux/mm.h	2010-01-30 18:09:58.000000000 +0800
@@ -1184,8 +1184,8 @@ int write_one_page(struct page *page, in
 void task_dirty_inc(struct task_struct *tsk);
 
 /* readahead.c */
-#define VM_MAX_READAHEAD	128	/* kbytes */
-#define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
+#define VM_MAX_READAHEAD	512	/* kbytes */
+#define VM_MIN_READAHEAD	32	/* kbytes (includes current page) */
 
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
