Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 21FC66B00D7
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 05:08:55 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2998lxK017078
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Mar 2009 18:08:47 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 77C5E45DE52
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 18:08:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5962C45DE51
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 18:08:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 44FB0E08006
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 18:08:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AB8831DB8013
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 18:08:43 +0900 (JST)
Date: Mon, 9 Mar 2009 18:07:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/4] memcg: add softlimit interface and utilitiy
 function.
Message-Id: <20090309180719.73e5e27d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090309085423.GJ24321@balbir.in.ibm.com>
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
	<20090309163907.a3cee183.kamezawa.hiroyu@jp.fujitsu.com>
	<20090309074449.GH24321@balbir.in.ibm.com>
	<20090309172911.312b0634.kamezawa.hiroyu@jp.fujitsu.com>
	<20090309085423.GJ24321@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Mar 2009 14:24:23 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 17:29:11]:
> 
> > On Mon, 9 Mar 2009 13:14:49 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 16:39:07]:
> > > 
> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > Adds an interface for defining sotlimit per memcg. (no handler in this patch.)
> > > > softlimit.priority and queue for softlimit is added in the next patch.
> > > > 
> > > > 
> > > > Changelog v1->v2:
> > > >  - For refactoring, divided a patch into 2 part and this patch just
> > > >    involves memory.softlimit interface.
> > > >  - Removed governor-detect routine, it was buggy in design.
> > > > 
> > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > ---
> > > >  mm/memcontrol.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
> > > >  1 file changed, 60 insertions(+), 2 deletions(-)
> > > 
> > > 
> > > This patch breaks the semantics of resource counters. We would like to
> > > use resource counters to track all overhead. I've refined my tracking
> > > to an extent that the overhead does not show up at all, unless soft
> > > limits kick in. I oppose keeping soft limits outside of resource
> > > counters.
> > > 
> > 
> > BTW, any other user of res_counter than memcg in future ?
> 
> None so far.. but we once the core controllers are developed (CPU,
> memory), I would expect IO, tasks, number of open files, etc to be
> potential exploiters.
> 
> > I'm afraid that res_counter is decolated as chocolate-cake and will not taste
> > good for people who wants simple counter as simple pancake...
> > 
> 
> 
> I think keeping the design modular has helped. This way we can
> optimize resource counters without touching any controller. Only when
> features are enabled is when people get the chocolate cake feeling,
> not otherwise.
> 

Hmm, maybe reducing overhead as per-cpu counter etc.. is necessary anyway.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
