Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id A89066B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 10:35:34 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 24 Aug 2012 20:05:31 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7OEZSXH6029650
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 20:05:28 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7OEZRNm014884
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 00:35:27 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 4/5] mm/memblock: use existing interface to set nid
Date: Fri, 24 Aug 2012 22:33:39 +0800
Message-Id: <1345818820-12102-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1345818820-12102-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1345818820-12102-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

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
