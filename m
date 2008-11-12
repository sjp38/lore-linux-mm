Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC3Qi7p014853
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 12:26:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D9E1E45DD77
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:26:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B437C45DD76
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:26:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C9421DB803F
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:26:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 54ED91DB8037
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:26:43 +0900 (JST)
Date: Wed, 12 Nov 2008 12:26:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/6] memcg updates (12/Nov/2008)
Message-Id: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Weekly updates on my queue.

Changes from previous (05/Nov)
 - added "free all at rmdir" patch.
 - fixed several bugs reported by Nishimura (Thanks!)
 - many style bugs are fixed.

Brief description:
[1/6].. free all at rmdir (and add attribute to memcg.)
[2/6].. handle swap cache
[3/6].. mem+swap controller kconfig
[4/6].. swap_cgroup
[5/6].. mem+swap controller
[6/6].. synchrinized LRU (unify lru lock.)

I think it's near to a month to test this mem+swap controller internally.
It's getting better. Making progress in step by step works good.

I'll send [1/6] and [2/6] to Andrew, tomorrow or weekend.(please do final check).

If no acks to [1/6] (I haven't got any ;), I'll postpone it and reschedule as [7/6].

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
