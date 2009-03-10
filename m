Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3CF0F6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 04:31:15 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2A8V965001076
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 14:01:09 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2A8S0Fm667820
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:58:00 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2A8V9Mh028202
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 19:31:09 +1100
Date: Tue, 10 Mar 2009 14:01:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/4] memcg: add softlimit interface and utilitiy
	function.
Message-ID: <20090310083102.GB26837@balbir.in.ibm.com>
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

I have two proposals currently in mind

1. Convert the basic counter to atomic_long, 32 bit systems might need
   more consideration, since they use int for atomic_t
2. Use seq_lock's and see if that helps scalability.

I'll try and get to them shortly, unless someone else gets to them
first.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
