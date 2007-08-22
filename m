Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7MNI9LN003076
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 19:18:09 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7MNI8ku207920
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 17:18:08 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7MNI840002838
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 17:18:08 -0600
Subject: [PATCH 3/9] pagemap: use PAGE_MASK/PAGE_ALIGN()
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 22 Aug 2007 16:18:06 -0700
References: <20070822231804.1132556D@kernel>
In-Reply-To: <20070822231804.1132556D@kernel>
Message-Id: <20070822231806.3413021A@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Use existing macros (PAGE_MASK/PAGE_ALIGN()) instead of
open-coding them.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 lxc-dave/fs/proc/task_mmu.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN fs/proc/task_mmu.c~pagemap-use-PAGE_MASK fs/proc/task_mmu.c
--- lxc/fs/proc/task_mmu.c~pagemap-use-PAGE_MASK	2007-08-22 16:16:51.000000000 -0700
+++ lxc-dave/fs/proc/task_mmu.c	2007-08-22 16:16:51.000000000 -0700
@@ -617,9 +617,9 @@ static ssize_t pagemap_read(struct file 
 		goto out;
 
 	ret = -ENOMEM;
-	uaddr = (unsigned long)buf & ~(PAGE_SIZE-1);
+	uaddr = (unsigned long)buf & PAGE_MASK;
 	uend = (unsigned long)(buf + count);
-	pagecount = (uend - uaddr + PAGE_SIZE-1) / PAGE_SIZE;
+	pagecount = (PAGE_ALIGN(uend) - uaddr) / PAGE_SIZE;
 	pages = kmalloc(pagecount * sizeof(struct page *), GFP_KERNEL);
 	if (!pages)
 		goto out_task;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
