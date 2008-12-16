Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4F4B46B007B
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 05:55:45 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBG9Aa9m009993
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Dec 2008 18:10:36 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3818745DE52
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:10:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 11C7E45DE4F
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:10:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F00B21DB8017
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:10:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AADC81DB8013
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:10:32 +0900 (JST)
Date: Tue, 16 Dec 2008 18:09:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg updates (2008/12/16)
Message-Id: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This is just for dumping my queue and sharing what is planned.

Including Paul Menage's "RFC" patches (because my patches uses them.)

Some are new and others are not. All are against mmotm-Dec-15.

[1/9] Bug fix for mem_cgroup_create() error path and simplify refcnt handling.
      (maybe it's better to divide this into bugfix and clean up.)
[2/9] Paul Menage's cgroup_hierarchy_mutex()
[3/9] Paul Menage's hierarchy_mutex_in_memcg
[4/9] Paul Menage's css_tryget()
[5/9] Add css_is_removed()
[6/9] Use css_tryget() in memcg to remove memcg->obsolete
[7/9] Add css_id support.
      A new implementation of cgroup ID I posted. IDs are per-CSS.
[8/9] Recalim memory in hierarchy withoug mutex of cgroups.
      Recalim memory in round-robin under hierarchy by CSS ID.
[9/9] Fix OOM killer bug under hierarchy.
      Current memcg' oom-killer is broken under hierarchy. This is a fix.

I wonder I have to keep 6-9 in my queue until the next year.
(2-5 aren't under my control.)

Piled up patches from memcg onto mmotm seems like a card tower ;)
So, I don't want to be aggressive.
If anyone interested in, fix 9/9 without 2-8.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
