Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CA1466B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 02:10:15 -0400 (EDT)
Date: Thu, 28 Apr 2011 08:10:13 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110428081013.7b0dd57a@pluto.restena.lu>
In-Reply-To: <20110427220717.GR2135@linux.vnet.ibm.com>
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
	<20110427220717.GR2135@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Wed, 27 Apr 2011 15:07:17 "Paul E. McKenney" wrote:
> On Wed, Apr 27, 2011 at 10:40:23PM +0200, Bruno Pr=C3=A9mont wrote:
> > On Wed, 27 April 2011 Bruno Pr=C3=A9mont wrote:
> > > On Wed, 27 April 2011 Bruno Pr=C3=A9mont wrote:
> > > > On Wed, 27 Apr 2011 00:28:37 +0200 (CEST) Thomas Gleixner wrote:
> > > > > Also please apply the patch below and check, whether the printk s=
hows
> > > > > up in your dmesg.
> > > >=20
> > > > > Index: linux-2.6-tip/kernel/sched_rt.c
> > > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > > --- linux-2.6-tip.orig/kernel/sched_rt.c
> > > > > +++ linux-2.6-tip/kernel/sched_rt.c
> > > > > @@ -609,6 +609,7 @@ static int sched_rt_runtime_exceeded(str
> > > > > =20
> > > > >  	if (rt_rq->rt_time > runtime) {
> > > > >  		rt_rq->rt_throttled =3D 1;
> > > > > +		printk_once(KERN_WARNING "sched: RT throttling activated\n");
> > >=20
> > > This gun is triggering right before RCU-managed slabs start piling up=
 as
> > > visible under slabtop so chances are it's at least a related!
> >=20
> > Letting the machine idle (except running collectd and slabtop) scheduler
> > suddenly decided to restart giving rcu_kthread CPU cycles (after two ho=
urs
> > or so! if I read my statistics graphs correctly)
>=20
> And this also returned the slab memory, right?

Exactly!

> Two hours is quite some time...
>=20
> 							Thanx, Paul
>=20
> > While looking at lkml during the above 2 hours I stumbled across this (=
the
> > patch of which doesn't help in my case) which looked possibly related.
> >   http://thread.gmane.org/gmane.linux.kernel/1129614
> >=20
> > Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
