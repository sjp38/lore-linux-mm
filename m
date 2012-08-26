Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 86F506B006E
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 05:00:55 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 26 Aug 2012 14:30:53 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7Q90ohd3932602
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 14:30:50 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7Q90nsd030764
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 19:00:50 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 3/4] mm/memblock: use existing interface to set nid
Date: Sun, 26 Aug 2012 17:00:25 +0800
Message-Id: <1345971626-17090-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1345971626-17090-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1345971626-17090-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

From: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use existing interface (function) to set NUMA node ID (NID) for
the regions, either memory or reserved region.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memblock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 880e461..3620493 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -756,7 +756,7 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
 		return ret;
 
 	for (i = start_rgn; i < end_rgn; i++)
-		type->regions[i].nid = nid;
+		memblock_set_region_node(&type->regions[i], nid);
 
 	memblock_merge_regions(type);
 	return 0;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
