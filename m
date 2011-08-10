Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF2CE900138
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 19:52:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2CECB3EE0AE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:52:18 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1247045DE7F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:52:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EB7AD45DE6A
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:52:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DDC3A1DB803C
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:52:17 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A7BE51DB8038
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:52:17 +0900 (JST)
Date: Thu, 11 Aug 2011 08:44:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: fix comment on update nodemask
Message-Id: <20110811084456.5da61183.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110811083043.a3b2ba65.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809190824.99347a0f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110810100042.GA15007@tiehlicka.suse.cz>
	<20110811083043.a3b2ba65.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>


> > >  /*
> > >   * Always updating the nodemask is not very good - even if we have an empty
> > >   * list or the wrong list here, we can start from some node and traverse all
> > > @@ -1575,7 +1593,6 @@ static bool test_mem_cgroup_node_reclaim
> > >   */
> > 
> > Would be good to update the function comment as well (we still have 10s
> > period there).
> > 
> 
how about this ?
==

Update function's comment. The behavior is changed by commit 453a9bf3

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

Index: mmotm-Aug3/mm/memcontrol.c
===================================================================
--- mmotm-Aug3.orig/mm/memcontrol.c
+++ mmotm-Aug3/mm/memcontrol.c
@@ -1568,10 +1568,7 @@ static bool test_mem_cgroup_node_reclaim
 #if MAX_NUMNODES > 1
 
 /*
- * Always updating the nodemask is not very good - even if we have an empty
- * list or the wrong list here, we can start from some node and traverse all
- * nodes based on the zonelist. So update the list loosely once per 10 secs.
- *
+ * Update scan nodemask with memcg's event_counter(NUMAINFO_EVENTS_TARGET)
  */
 static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
