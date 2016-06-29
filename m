Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92198828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 14:12:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so55430432wmr.0
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 11:12:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v67si209445wma.35.2016.06.29.11.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 11:12:12 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5TIAa0j138110
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 14:12:10 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23v09pxewc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 14:12:10 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 29 Jun 2016 12:12:09 -0600
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id BE3E33E40041
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 12:12:07 -0600 (MDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5TIC82039387328
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 18:12:08 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5TIC6YX020448
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 14:12:07 -0400
Date: Wed, 29 Jun 2016 11:12:08 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Reply-To: paulmck@linux.vnet.ibm.com
References: <20160622005208.GB25106@js1304-P5Q-DELUXE>
 <CAMuHMdW-wSxASozhmPh0b+9UJFFVbYHqTqH5e9P1oO7T59YE7g@mail.gmail.com>
 <20160622190859.GA1473@linux.vnet.ibm.com>
 <20160623004935.GA20752@linux.vnet.ibm.com>
 <20160623023756.GA30438@js1304-P5Q-DELUXE>
 <20160623024742.GD1473@linux.vnet.ibm.com>
 <20160623025329.GA13095@linux.vnet.ibm.com>
 <CAMuHMdVqNV5ZbR3_NV5ZsLxoNQUXXGpfAcaoMJffaJbRPUb6-A@mail.gmail.com>
 <20160629164415.GG4650@linux.vnet.ibm.com>
 <CAMuHMdUfQ-gBqjZGvawf5zxgb-0UnWb+fzD-kcWU+kavwvadgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdUfQ-gBqjZGvawf5zxgb-0UnWb+fzD-kcWU+kavwvadgQ@mail.gmail.com>
Message-Id: <20160629181208.GP4650@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Linux MM <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jun 29, 2016 at 07:52:06PM +0200, Geert Uytterhoeven wrote:
> Hi Paul,
> 
> On Wed, Jun 29, 2016 at 6:44 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Wed, Jun 29, 2016 at 04:54:44PM +0200, Geert Uytterhoeven wrote:
> >> On Thu, Jun 23, 2016 at 4:53 AM, Paul E. McKenney
> >> <paulmck@linux.vnet.ibm.com> wrote:
> >> > On Wed, Jun 22, 2016 at 07:47:42PM -0700, Paul E. McKenney wrote:
> >
> > [ . . . ]
> >
> >> > @@ -4720,11 +4720,18 @@ static void __init rcu_dump_rcu_node_tree(struct rcu_state *rsp)
> >> >                         pr_info(" ");
> >> >                         level = rnp->level;
> >> >                 }
> >> > -               pr_cont("%d:%d ^%d  ", rnp->grplo, rnp->grphi, rnp->grpnum);
> >> > +               pr_cont("%d:%d/%#lx/%#lx ^%d  ", rnp->grplo, rnp->grphi,
> >> > +                       rnp->qsmask,
> >> > +                       rnp->qsmaskinit | rnp->qsmaskinitnext, rnp->grpnum);
> >> >         }
> >> >         pr_cont("\n");
> >> >  }
> >>
> >> For me it always crashes during the 37th call of synchronize_sched() in
> >> setup_kmem_cache_node(), which is the first call after secondary CPU bring up.
> >> With your and my debug code, I get:
> >>
> >>   CPU: Testing write buffer coherency: ok
> >>   CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
> >>   Setting up static identity map for 0x40100000 - 0x40100058
> >>   cnt = 36, sync
> >>   CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
> >>   Brought up 2 CPUs
> >>   SMP: Total of 2 processors activated (2132.00 BogoMIPS).
> >>   CPU: All CPU(s) started in SVC mode.
> >>   rcu_node tree layout dump
> >>    0:1/0x0/0x3 ^0
> >
> > Thank you for running this!
> >
> > OK, so RCU knows about both CPUs (the "0x3"), and the previous
> > grace period has seen quiescent states from both of them (the "0x0").
> > That would indicate that your synchronize_sched() showed up when RCU was
> > idle, so it had to start a new grace period.  It also rules out failure
> > modes where RCU thinks that there are more CPUs than really exist.
> > (Don't laugh, such things have really happened.)
> >
> >>   devtmpfs: initialized
> >>   VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 1
> >>   clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,
> >> max_idle_ns: 19112604462750000 ns
> >>
> >> I hope it helps. Thanks!
> >
> > I am going to guess that this was the first grace period since the second
> > CPU came online.  When there only on CPU online, synchronize_sched()
> > is a no-op.
> >
> > OK, this showed some things that aren't a problem.  What might the
> > problem be?
> >
> > o       The grace-period kthread has not yet started.  It -should- start
> >         at early_initcall() time, but who knows?  Adding code to print
> >         out that kthread's task_struct address.
> >
> > o       The grace-period kthread might not be responding to wakeups.
> >         Checking this requires that a grace period be in progress,
> >         so please put a call_rcu_sched() just before the call to
> >         rcu_dump_rcu_node_tree().  (Sample code below.)  Adding code
> >         to my patch to print out more GP-kthread state as well.
> >
> > o       One of the CPUs might not be responding to RCU.  That -should-
> >         result in an RCU CPU stall warning, so I will ignore this
> >         possibility for the moment.
> >
> >         That said, do you have some way to determine whether scheduling
> >         clock interrupts are really happening?  Without these interrupts,
> >         no RCU CPU stall warnings.
> 
> I believe there are no clocksources yet. The jiffies clocksource is the first
> clocksource found, and that happens after the first call to
> synchronize_sched(), cfr. my dmesg snippet above.
> 
> In a working boot:
> # cat /sys/bus/clocksource/devices/clocksource0/available_clocksource
> e0180000.timer jiffies
> # cat /sys/bus/clocksource/devices/clocksource0/current_clocksource
> e0180000.timer

Ah!  But if there is no jiffies clocksource, then schedule_timeout()
and friends will never return, correct?  If so, I guarantee you that
synchronize_sched() will unconditionally hang.

So if I understand correctly, the fix is to get the jiffies clocksource
running before the first call to synchronize_sched().

							Thanx, Paul

> > OK, that should be enough for the next phase, please see the end for the
> > patch.  This patch applies on top of my previous one.
> >
> > Could you please set this up as follows?
> >
> >         struct rcu_head rh;
> >
> >         rcu_dump_rcu_node_tree(&rcu_sched_state);  /* Initial state. */
> >         call_rcu(&rh, do_nothing_cb);
> 
> I added an empty do_nothing_cb() for this:
> 
>     static void do_nothing_cb(struct rcu_head *rcu_head)
>     {
>     }
> 
> According to the debugging technique "comment everything out until it boots",
> it now hangs in call_rcu().
> 
> >         schedule_timeout_uninterruptible(5 * HZ);  /* Or whatever delay. */
> >         rcu_dump_rcu_node_tree(&rcu_sched_state);  /* GP state. */
> >         synchronize_sched();  /* Probably hangs. */
> >         rcu_barrier();  /* Drop RCU's references to rh before return. */
> 
> Thanks!
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
