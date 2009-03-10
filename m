Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A79ED6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 04:03:39 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2A83NRU021058
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 19:03:23 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2A83mD2413782
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 19:03:50 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2A83ULb018858
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 19:03:30 +1100
Date: Tue, 10 Mar 2009 13:33:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/4] memcg: add softlimit interface and utilitiy
	function.
Message-ID: <20090310080323.GA26837@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com> <20090309163907.a3cee183.kamezawa.hiroyu@jp.fujitsu.com> <20090309074449.GH24321@balbir.in.ibm.com> <20090309165507.9f57ad41.kamezawa.hiroyu@jp.fujitsu.com> <20090309084844.GI24321@balbir.in.ibm.com> <20090310145334.0473c3fe.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090310145334.0473c3fe.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-10 14:53:34]:

> On Mon, 9 Mar 2009 14:18:44 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 16:55:07]:
> > 
> > > On Mon, 9 Mar 2009 13:14:49 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 16:39:07]:
> > > Hmm, them, moving mem->softlimit to res->softlimit is ok ?
> > > 
> > > If no more "branch" to res_counter_charge/uncharge(), moving this to
> > > res_counter is ok to me.
> > >
> > 
> > There is a branch, but the additional excessive checks are gone.
> > It should be possible to reduce the overhead to comparisons though. 
> > 
> 
> I'm now rewriting to use res_counter but do you have any good reason to
> irq-off in res_counter ?
> It seems there are no callers in irq path.

It has been on my TODO list to make resource counter more efficient.
The reason for irq disabling is because counters routines can get called from
reclaim with irq's disabled as well.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
