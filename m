Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC3XqiO017507
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 12:33:52 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D8E82AEA81
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:33:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B0BF1EF083
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:33:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 369931DB803C
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:33:52 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E65E31DB803A
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:33:51 +0900 (JST)
Date: Wed, 12 Nov 2008 12:33:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/6] memcg updates (12/Nov/2008)
Message-Id: <20081112123315.3edcc39f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 12:26:06 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Weekly updates on my queue.
> 
> Changes from previous (05/Nov)
>  - added "free all at rmdir" patch.
>  - fixed several bugs reported by Nishimura (Thanks!)
>  - many style bugs are fixed.
> 
> Brief description:
> [1/6].. free all at rmdir (and add attribute to memcg.)
> [2/6].. handle swap cache
> [3/6].. mem+swap controller kconfig
> [4/6].. swap_cgroup
> [5/6].. mem+swap controller
> [6/6].. synchrinized LRU (unify lru lock.)
> 
> I think it's near to a month to test this mem+swap controller internally.
> It's getting better. Making progress in step by step works good.
> 
> I'll send [1/6] and [2/6] to Andrew, tomorrow or weekend.(please do final check).
> 
> If no acks to [1/6] (I haven't got any ;), I'll postpone it and reschedule as [7/6].
> 
Ah, sorry. 
All are based on "The mm-of-the-moment snapshot 2008-11-10-14-54".


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
