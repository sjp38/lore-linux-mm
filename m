Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7MNIDk4025440
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 19:18:13 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7MNICPx270432
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 17:18:12 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7MNICbd002962
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 17:18:12 -0600
Subject: [PATCH 6/9] pagemap: give -1's a name
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 22 Aug 2007 16:18:10 -0700
References: <20070822231804.1132556D@kernel>
In-Reply-To: <20070822231804.1132556D@kernel>
Message-Id: <20070822231810.27E079C8@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

-1 is a magic number in /proc/$pid/pagemap.  It means that
there was no pte present for a particular page.  We're
going to be refining that a bit shortly, so give this a
real name for now.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 lxc-dave/fs/proc/task_mmu.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN fs/proc/task_mmu.c~give_-1s_a_name fs/proc/task_mmu.c
--- lxc/fs/proc/task_mmu.c~give_-1s_a_name	2007-08-22 16:16:53.000000000 -0700
+++ lxc-dave/fs/proc/task_mmu.c	2007-08-22 16:16:53.000000000 -0700
@@ -509,6 +509,7 @@ struct pagemapread {
 };
 
 #define PM_ENTRY_BYTES sizeof(unsigned long)
+#define PM_NOT_PRESENT ((unsigned long)-1)
 
 static int add_to_pagemap(unsigned long addr, unsigned long pfn,
 			  struct pagemapread *pm)
@@ -533,7 +534,7 @@ static int pagemap_pte_range(pmd_t *pmd,
 		if (addr < pm->next)
 			continue;
 		if (!pte_present(*pte))
-			err = add_to_pagemap(addr, -1, pm);
+			err = add_to_pagemap(addr, PM_NOT_PRESENT, pm);
 		else
 			err = add_to_pagemap(addr, pte_pfn(*pte), pm);
 		if (err)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
