Date: Tue, 8 May 2007 21:04:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] change zonelist order v5 [4/3] compile fix.....
Message-Id: <20070508210408.50cafc47.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, clameter@sgi.com, akpm@linux-foundation.org, ak@suse.de, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

I'm very sorry for missing this fix for non-NUMA arch...
I'll repost the whole set if necessary....
-Kame

Compile-fix...

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.21-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/page_alloc.c
+++ linux-2.6.21-mm1/mm/page_alloc.c
@@ -2321,6 +2321,7 @@ static void build_zonelists(pg_data_t *p
 	prev_node = local_node;
 	nodes_clear(used_mask);
 
+	memset(node_load, 0, sizeof(node_load));
 	memset(node_order, 0, sizeof(node_order));
 	j = 0;
 
@@ -2455,7 +2456,6 @@ void build_all_zonelists(void)
 		__build_all_zonelists(&order);
 		cpuset_init_current_mems_allowed();
 	} else {
-		memset(node_load, 0, sizeof(node_load));
 		/* we have to stop all cpus to guaranntee there is no user
 		   of zonelist */
 		stop_machine_run(__build_all_zonelists, &order, NR_CPUS);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
