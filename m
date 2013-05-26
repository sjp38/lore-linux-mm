Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 173376B0071
	for <linux-mm@kvack.org>; Sun, 26 May 2013 01:58:58 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 26 May 2013 11:22:51 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 6A54D3940053
	for <linux-mm@kvack.org>; Sun, 26 May 2013 11:28:52 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4Q5wgBL7340492
	for <linux-mm@kvack.org>; Sun, 26 May 2013 11:28:43 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4Q5wmrC004150
	for <linux-mm@kvack.org>; Sun, 26 May 2013 15:58:49 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 2/6] mm/memory_hotplug: remove memory_add_physaddr_to_nid
Date: Sun, 26 May 2013 13:58:37 +0800
Message-Id: <1369547921-24264-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

memory_add_physaddr_to_nid is not used any more, this patch remove it.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 arch/x86/mm/numa.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index a71c4e2..d470a54 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -803,18 +803,3 @@ const struct cpumask *cpumask_of_node(int node)
 EXPORT_SYMBOL(cpumask_of_node);
 
 #endif	/* !CONFIG_DEBUG_PER_CPU_MAPS */
-
-#ifdef CONFIG_MEMORY_HOTPLUG
-int memory_add_physaddr_to_nid(u64 start)
-{
-	struct numa_meminfo *mi = &numa_meminfo;
-	int nid = mi->blk[0].nid;
-	int i;
-
-	for (i = 0; i < mi->nr_blks; i++)
-		if (mi->blk[i].start <= start && mi->blk[i].end > start)
-			nid = mi->blk[i].nid;
-	return nid;
-}
-EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
-#endif
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
