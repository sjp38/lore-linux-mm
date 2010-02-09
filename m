Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 75D916001DA
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 06:29:09 -0500 (EST)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: [PATCH] Remove unused macro, VM_MIN_READAHEAD.
Date: Tue, 9 Feb 2010 16:59:19 +0530
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201002091659.19988.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

Remove unused macro, VM_MIN_READAHEAD.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

---

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -1189,7 +1189,6 @@ void task_dirty_inc(struct task_struct *
 
 /* readahead.c */
 #define VM_MAX_READAHEAD	128	/* kbytes */
-#define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
 
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
