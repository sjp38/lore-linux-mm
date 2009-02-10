Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8F5626B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 04:50:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1A9ofwN021086
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 18:50:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E57B45DE57
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 18:50:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E338245DE61
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 18:50:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90E20E18001
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 18:50:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BABFE38004
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 18:50:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] memcg: remove mem_cgroup_reclaim_imbalance() perfectly
Message-Id: <20090210184538.6FCF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 18:50:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


commit 4f98a2fee8acdb4ac84545df98cccecfd130f8db (vmscan: 
split LRU lists into anon & file sets) remove mem_cgroup_reclaim_imbalance().

but it isn't enough.
memcontrol.h header file still have legacy parts.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 include/linux/memcontrol.h |    6 ------
 1 file changed, 6 deletions(-)

Index: b/include/linux/memcontrol.h
===================================================================
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -88,7 +88,6 @@ extern void mem_cgroup_end_migration(str
 /*
  * For memory reclaim.
  */
-extern long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
@@ -202,11 +201,6 @@ static inline void mem_cgroup_end_migrat
 {
 }
 
-static inline int mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem)
-{
-	return 0;
-}
-
 static inline bool mem_cgroup_disabled(void)
 {
 	return true;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
