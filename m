Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A398F6B00D5
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 04:54:33 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n298sPd5030404
	for <linux-mm@kvack.org>; Mon, 9 Mar 2009 14:24:25 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n298sX2A3190786
	for <linux-mm@kvack.org>; Mon, 9 Mar 2009 14:24:33 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n298sPfn000952
	for <linux-mm@kvack.org>; Mon, 9 Mar 2009 19:54:25 +1100
Date: Mon, 9 Mar 2009 14:24:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/4] memcg: add softlimit interface and utilitiy
	function.
Message-ID: <20090309085423.GJ24321@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com> <20090309163907.a3cee183.kamezawa.hiroyu@jp.fujitsu.com> <20090309074449.GH24321@balbir.in.ibm.com> <20090309172911.312b0634.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090309172911.312b0634.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 17:29:11]:

> On Mon, 9 Mar 2009 13:14:49 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 16:39:07]:
> > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Adds an interface for defining sotlimit per memcg. (no handler in this patch.)
> > > softlimit.priority and queue for softlimit is added in the next patch.
> > > 
> > > 
> > > Changelog v1->v2:
> > >  - For refactoring, divided a patch into 2 part and this patch just
> > >    involves memory.softlimit interface.
> > >  - Removed governor-detect routine, it was buggy in design.
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > >  mm/memcontrol.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
> > >  1 file changed, 60 insertions(+), 2 deletions(-)
> > 
> > 
> > This patch breaks the semantics of resource counters. We would like to
> > use resource counters to track all overhead. I've refined my tracking
> > to an extent that the overhead does not show up at all, unless soft
> > limits kick in. I oppose keeping soft limits outside of resource
> > counters.
> > 
> 
> BTW, any other user of res_counter than memcg in future ?

None so far.. but we once the core controllers are developed (CPU,
memory), I would expect IO, tasks, number of open files, etc to be
potential exploiters.

> I'm afraid that res_counter is decolated as chocolate-cake and will not taste
> good for people who wants simple counter as simple pancake...
> 


I think keeping the design modular has helped. This way we can
optimize resource counters without touching any controller. Only when
features are enabled is when people get the chocolate cake feeling,
not otherwise.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
