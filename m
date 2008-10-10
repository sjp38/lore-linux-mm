Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9A8xs1r014549
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Oct 2008 17:59:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 338452AC025
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 17:59:54 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A19E12C047
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 17:59:54 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id E4B851DB803A
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 17:59:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id A3C4F1DB8038
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 17:59:53 +0900 (JST)
Date: Fri, 10 Oct 2008 17:59:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/5] memcg: more updates (still under test) v7
Message-Id: <20081010175936.f3b1f4e0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is just-for-test sets.

ready-to-go set (v7 http://marc.info/?l=linux-mm&m=122353662107309&w=2)
can be applied to the latest mmotm(stamp-2008-10-09-21-35) with small easy
Hunk. (change in mm_types.h show HUNK) So I don't send it again now.

While it seems I have to maintain ready-to-go set by myself until the end of
merge window, I'd like to share patches on my stack and restart Mem+Swap
controller at el.

This set includes following patches

[1/5] ....charge/commit/cancel protcol
[2/5] ....fix for page migration handling (I hope this will be silver bullet.)
[3/5] ....new force_empty() and move_account()
[4/5] ....lazy lru free
[5/5] ....lazy lru add.

I'm still testing this but dump it now before weekend. (works well as far as my
test.) I'll restart Mem+Swap controller from scratch in the next week.

If you want me to do other work rather than Mem+Swap controller, don't hesitate
to request me. I may not notice that any important work should be done before
complicated tasks.
tasks on my queue is..
  - Mem+Swap controller.
  - an interface to shrink memory usage of a group.
  - move account at task move (maybe complicated.)
  - swappiness support (after split-lru setteld.)
  - dirty_ratio (Andrea Righi's work will go.)
  - priority to memory reclaim. (can we ?)
  - hierarchy support. (needs discusstion for trade-off among performance/function.)
  - NUMA statistics (this needs cgroup interface enhancements.)

And maybe we need more performance check.

Bye,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
