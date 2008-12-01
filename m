Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB1A1Ar7022875
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 19:01:10 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5741D2AEA8D
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 19:01:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32ED01EF083
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 19:01:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1784E1DB803C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 19:01:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA5741DB8040
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 19:01:09 +0900 (JST)
Date: Mon, 1 Dec 2008 19:00:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] memcg: unified easy patch series for mmotm-Nov30
Message-Id: <20081201190021.f3ab1f17.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, nickpiggin@yahoo.com.au, knikanth@suse.de, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch series are fixed and clean-up agasist
 "mm-of-the-moment snapshot 2008-11-30-22-35"

Picked up useful ones from recent linux-mm.
patches are numbered but I think each can be applied one by one independently.

[1/4] clean up move_tasks of memcg.
	(From Nikanth Karthikesan <knikanth@suse.de>)
	Obvious change.

[2/4] fixes mem+swap controller's limit check
	(From Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>)
	Maybe Ack from Balbir is appropriate.

[3/4] clean up gfp_mask passed to memcg.
	From me. I want a review by Hugh Dickins and Nick Piggin. please.

[4/4] fix the name of scan_global_lru().
	From me. Obvious change.

I'll queue Kosaki's memcg LRU fixes and cgroup-ID based on this.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
