Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 53A948D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:28:05 -0400 (EDT)
Date: Tue, 29 Mar 2011 15:28:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [trivial PATCH] Remove pointless next_mz nullification in
 mem_cgroup_soft_limit_reclaim
Message-ID: <20110329132800.GA3361@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi,
while reading the code I have encountered the following thing. It is no
biggie but...
---
From: Michal Hocko <mhocko@suse.cz>
Subject: Remove pointless next_mz nullification in mem_cgroup_soft_limit_reclaim

next_mz is assigned to NULL if __mem_cgroup_largest_soft_limit_node selects
the same mz. This doesn't make much sense as we assign to the variable
right in the next loop.

Compiler will probably optimize this out but it is little bit confusing for
the code reading.

Signed-off-by: Michal Hocko <mhocko@suse.cz>

Index: linux-2.6.38-rc8/mm/memcontrol.c
===================================================================
--- linux-2.6.38-rc8.orig/mm/memcontrol.c	2011-03-28 11:25:14.000000000 +0200
+++ linux-2.6.38-rc8/mm/memcontrol.c	2011-03-29 15:24:08.000000000 +0200
@@ -3349,7 +3349,6 @@ unsigned long mem_cgroup_soft_limit_recl
 				__mem_cgroup_largest_soft_limit_node(mctz);
 				if (next_mz == mz) {
 					css_put(&next_mz->mem->css);
-					next_mz = NULL;
 				} else /* next_mz == NULL or other memcg */
 					break;
 			} while (1);
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
