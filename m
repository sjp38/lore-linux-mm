Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E86E76B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 21:03:00 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n6S12wS2017105
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 02:02:58 +0100
Received: from pxi39 (pxi39.prod.google.com [10.243.27.39])
	by spaceape11.eur.corp.google.com with ESMTP id n6S12s4R015687
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 18:02:56 -0700
Received: by pxi39 with SMTP id 39so666999pxi.30
        for <linux-mm@kvack.org>; Mon, 27 Jul 2009 18:02:54 -0700 (PDT)
Date: Mon, 27 Jul 2009 18:02:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <20090728095453.1fe79de1.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907271758170.29815@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com> <1247679064.4089.26.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com> <alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
 <20090724160936.a3b8ad29.akpm@linux-foundation.org> <337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com> <5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com> <9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
 <alpine.DEB.2.00.0907271047590.8408@chino.kir.corp.google.com> <20090728085810.f7ae678a.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0907271710590.27881@chino.kir.corp.google.com> <20090728092529.bb0d7e9c.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0907271731040.29815@chino.kir.corp.google.com> <20090728095453.1fe79de1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Jul 2009, KAMEZAWA Hiroyuki wrote:

> > The problem originally reported here doesn't appear to have anything to do 
> > with hotplug, it looks like it is the result of Lee's observation that 
> > ia64 defaults top_cpuset's mems to N_POSSIBLE, which _should_ have been 
> > updated by cpuset_init_smp(). 
> cpuset_init_smp() just updates cpuset's mask.
> init's task->mems_allowed is intizialized independently from cpuset's mask.
> 

Presumably the bug is that N_HIGH_MEMORY is not a subset of N_ONLINE at 
this point on ia64.

> Could you teach me a pointer for Lee's observation ?
> 

http://marc.info/?l=linux-kernel&m=124767909310293

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
