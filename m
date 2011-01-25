Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C48C66B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 01:07:56 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B58B83EE0C0
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:07:54 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A10D645DE58
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:07:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C9A245DE55
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:07:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 71395E78001
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:07:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BF09E08002
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:07:54 +0900 (JST)
Date: Tue, 25 Jan 2011 15:01:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/3] memcg: bugfix check mem_cgroup_disabled() at split
 fixup
Message-Id: <20110125150153.b16c4de3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110125145720.cd0cbe16.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110125145720.cd0cbe16.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

mem_cgroup_disabled() should be checked at splitting.
If diabled, no heavy work is necesary.

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6.38-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.38-rc2.orig/mm/memcontrol.c
+++ linux-2.6.38-rc2/mm/memcontrol.c
@@ -2145,6 +2145,8 @@ void mem_cgroup_split_huge_fixup(struct 
 	struct page_cgroup *tail_pc = lookup_page_cgroup(tail);
 	unsigned long flags;
 
+	if (mem_cgroup_disabled())
+		return;
 	/*
 	 * We have no races with charge/uncharge but will have races with
 	 * page state accounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
