Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5723F6B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 21:13:56 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6S1Du35009644
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Jul 2009 10:13:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0838B45DE60
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 10:13:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D728145DE4D
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 10:13:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BC71F1DB8037
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 10:13:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 656111DB8043
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 10:13:52 +0900 (JST)
Date: Tue, 28 Jul 2009 10:11:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
Message-Id: <20090728101157.9465b2e5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0907271758170.29815@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
	<1247679064.4089.26.camel@useless.americas.hpqcorp.net>
	<alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
	<alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
	<20090724160936.a3b8ad29.akpm@linux-foundation.org>
	<337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com>
	<5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com>
	<9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0907271047590.8408@chino.kir.corp.google.com>
	<20090728085810.f7ae678a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907271710590.27881@chino.kir.corp.google.com>
	<20090728092529.bb0d7e9c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907271731040.29815@chino.kir.corp.google.com>
	<20090728095453.1fe79de1.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907271758170.29815@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jul 2009 18:02:50 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 28 Jul 2009, KAMEZAWA Hiroyuki wrote:
> 
> > > The problem originally reported here doesn't appear to have anything to do 
> > > with hotplug, it looks like it is the result of Lee's observation that 
> > > ia64 defaults top_cpuset's mems to N_POSSIBLE, which _should_ have been 
> > > updated by cpuset_init_smp(). 
> > cpuset_init_smp() just updates cpuset's mask.
> > init's task->mems_allowed is intizialized independently from cpuset's mask.
> > 
> 
> Presumably the bug is that N_HIGH_MEMORY is not a subset of N_ONLINE at 
> this point on ia64.
> 
N_HIGH_MEMORY is must be subset of N_ONLINE, at the any moment. Hmm,
I'll look into what happens in ia64 world.

> > Could you teach me a pointer for Lee's observation ?
> > 
> 
> http://marc.info/?l=linux-kernel&m=124767909310293
> 
Aha, my patch is very similar to Lee's one.
And he said "hotplug is issue", yes. it is.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
