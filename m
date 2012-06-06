Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9C0BD6B0070
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 04:15:18 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 1/7] highmem: rearrange export symbol of __kmap_atomic_idx
Date: Wed, 6 Jun 2012 16:14:55 +0800
Message-Id: <1338970501-5098-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@linux.intel.com>, Ian Campbell <ian.campbell@citrix.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

make it near to its defintion.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/highmem.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 57d82c6..0036dd5 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -32,6 +32,7 @@
 
 #if defined(CONFIG_HIGHMEM) || defined(CONFIG_X86_32)
 DEFINE_PER_CPU(int, __kmap_atomic_idx);
+EXPORT_PER_CPU_SYMBOL(__kmap_atomic_idx);
 #endif
 
 /*
@@ -47,9 +48,6 @@ DEFINE_PER_CPU(int, __kmap_atomic_idx);
 unsigned long totalhigh_pages __read_mostly;
 EXPORT_SYMBOL(totalhigh_pages);
 
-
-EXPORT_PER_CPU_SYMBOL(__kmap_atomic_idx);
-
 unsigned int nr_free_highpages (void)
 {
 	pg_data_t *pgdat;
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
