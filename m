Date: Fri, 9 Nov 2007 07:11:12 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 3/6 mm] memcgroup: fix try_to_free order
In-Reply-To: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0711090710310.21663@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Why does try_to_free_mem_cgroup_pages try for order 1 pages?  It's called
when mem_cgroup_charge_common would go over the limit, and that's adding
an order 0 page.  I see no reason: it has to be a typo: fix it.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Insert just after memory-controller-add-per-container-lru-and-reclaim-v7.patch

 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- patch2/mm/vmscan.c	2007-11-08 15:46:21.000000000 +0000
+++ patch3/mm/vmscan.c	2007-11-08 15:48:08.000000000 +0000
@@ -1354,7 +1354,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
-		.order = 1,
+		.order = 0,
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
 	};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
