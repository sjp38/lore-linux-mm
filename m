Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DC4366B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:07:23 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3RLisNL007614
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:44:54 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3RM7LNt467010
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:07:21 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3RM7If0027689
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:07:21 -0400
Date: Wed, 27 Apr 2011 15:07:17 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110427220717.GR2135@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110425214933.GO2468@linux.vnet.ibm.com>
 <20110426081904.0d2b1494@pluto.restena.lu>
 <20110426112756.GF4308@linux.vnet.ibm.com>
 <20110426183859.6ff6279b@neptune.home>
 <20110426190918.01660ccf@neptune.home>
 <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
 <alpine.LFD.2.02.1104262314110.3323@ionos>
 <20110427081501.5ba28155@pluto.restena.lu>
 <20110427204139.1b0ea23b@neptune.home>
 <20110427224023.10bd4f33@neptune.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110427224023.10bd4f33@neptune.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Wed, Apr 27, 2011 at 10:40:23PM +0200, Bruno Premont wrote:
> On Wed, 27 April 2011 Bruno Premont wrote:
> > On Wed, 27 April 2011 Bruno Premont wrote:
> > > On Wed, 27 Apr 2011 00:28:37 +0200 (CEST) Thomas Gleixner wrote:
> > > > Also please apply the patch below and check, whether the printk shows
> > > > up in your dmesg.
> > > 
> > > > Index: linux-2.6-tip/kernel/sched_rt.c
> > > > ===================================================================
> > > > --- linux-2.6-tip.orig/kernel/sched_rt.c
> > > > +++ linux-2.6-tip/kernel/sched_rt.c
> > > > @@ -609,6 +609,7 @@ static int sched_rt_runtime_exceeded(str
> > > >  
> > > >  	if (rt_rq->rt_time > runtime) {
> > > >  		rt_rq->rt_throttled = 1;
> > > > +		printk_once(KERN_WARNING "sched: RT throttling activated\n");
> > 
> > This gun is triggering right before RCU-managed slabs start piling up as
> > visible under slabtop so chances are it's at least a related!
> 
> Letting the machine idle (except running collectd and slabtop) scheduler
> suddenly decided to restart giving rcu_kthread CPU cycles (after two hours
> or so! if I read my statistics graphs correctly)

And this also returned the slab memory, right?

Two hours is quite some time...

							Thanx, Paul

> While looking at lkml during the above 2 hours I stumbled across this (the
> patch of which doesn't help in my case) which looked possibly related.
>   http://thread.gmane.org/gmane.linux.kernel/1129614
> 
> Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
