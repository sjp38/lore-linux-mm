Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 75A7A6B0072
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 04:15:20 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 2/7] highmem: rearrange the comments of pkmap_count
Date: Wed, 6 Jun 2012 16:14:56 +0800
Message-Id: <1338970501-5098-2-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1338970501-5098-1-git-send-email-laijs@cn.fujitsu.com>
References: <1338970501-5098-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@linux.intel.com>, Ian Campbell <ian.campbell@citrix.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

make it near to its defintion.
also change Virtual_count to pkmap_count in the comments.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/highmem.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 0036dd5..54c0521 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -35,14 +35,6 @@ DEFINE_PER_CPU(int, __kmap_atomic_idx);
 EXPORT_PER_CPU_SYMBOL(__kmap_atomic_idx);
 #endif
 
-/*
- * Virtual_count is not a pure "count".
- *  0 means that it is not mapped, and has not been mapped
- *    since a TLB flush - it is usable.
- *  1 means that there are no users, but it has been mapped
- *    since the last TLB flush - so we can't use it.
- *  n means that there are (n-1) current users of it.
- */
 #ifdef CONFIG_HIGHMEM
 
 unsigned long totalhigh_pages __read_mostly;
@@ -65,6 +57,14 @@ unsigned int nr_free_highpages (void)
 	return pages;
 }
 
+/*
+ * pkmap_count is not a pure "count".
+ *  0 means that it is not mapped, and has not been mapped
+ *    since a TLB flush - it is usable.
+ *  1 means that there are no users, but it has been mapped
+ *    since the last TLB flush - so we can't use it.
+ *  n means that there are (n-1) current users of it.
+ */
 static int pkmap_count[LAST_PKMAP];
 static unsigned int last_pkmap_nr;
 static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(kmap_lock);
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
