Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 52B036B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 02:29:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V6UBPJ018877
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 15:30:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9130F45DE64
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:30:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 69A1E45DE51
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:30:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B5FCE38009
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:30:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A00931DB804B
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:30:10 +0900 (JST)
Date: Tue, 31 Mar 2009 15:28:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-Id: <20090331152843.e1db942b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090331061010.GJ16497@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090328181100.GB26686@balbir.in.ibm.com>
	<20090328182747.GA8339@balbir.in.ibm.com>
	<20090331085538.2aaa5e2b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331050055.GF16497@balbir.in.ibm.com>
	<20090331140502.813993cc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331061010.GJ16497@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 11:40:10 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > > Swapout for A? For A it is expected, but for B it is not. How many
> > > nodes do you have on your machine? Any fake numa nodes?
> > > 
> > Of course, from B.
> >
> 
> I asked because I see A have a swapout of 350 MB, which is expected
> since it is way over its soft limit.
>  
gcc doesn't use so much RSS..ld ?

> > Nothing special boot options. My test was on VMware 2cpus/1.6GB memory.
> > 
> > I wonder why swapout can be 0 on your test. Do you add some extra hooks to
> > kswapd ?
> >
> 
> Nope.. no special hooks to kswapd. B never enters the RB-Tree and thus
> never hits the memcg soft limit reclaim path. kswapd can reclaim from
> it, but it grows back quickly.
Why grows back ? tasks in B sleeps ?

>  At some point, memcg soft limit reclaim
> hits A and reclaims memory from it, allowing B to run without any
> problems. I am talking about the state at the end of the experiment.
> 
Considering LRU rotation (ACTIVE->INACTIVE), pages in group B never goes back
to ACTIVE list and can be the first candidates for swap-out via kswapd.

Hmm....kswapd doesn't work at all ?

(or 1700MB was too much.)

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
