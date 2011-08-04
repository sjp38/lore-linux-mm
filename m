Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 80FEA900138
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 11:58:35 -0400 (EDT)
Subject: Re: select_task_rq_fair: WARNING: at kernel/lockdep.c
 match_held_lock
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110804155347.GB3562@swordfish.minsk.epam.com>
References: <20110804141306.GA3536@swordfish.minsk.epam.com>
	 <1312470358.16729.25.camel@twins>
	 <20110804153752.GA3562@swordfish.minsk.epam.com>
	 <1312472867.16729.38.camel@twins>
	 <20110804155347.GB3562@swordfish.minsk.epam.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 04 Aug 2011 17:57:53 +0200
Message-ID: <1312473473.16729.44.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 2011-08-04 at 18:53 +0300, Sergey Senozhatsky wrote:
> On (08/04/11 17:47), Peter Zijlstra wrote:
> > On Thu, 2011-08-04 at 18:37 +0300, Sergey Senozhatsky wrote:
> > > > > [  132.794685] WARNING: at kernel/lockdep.c:3117 match_held_lock+=
0xf6/0x12e()
> >=20
> > Just to double check, that line is:
> >=20
> >                 if (DEBUG_LOCKS_WARN_ON(!hlock->nest_lock))
> >=20
> > in your kernel source?
> >=20
>=20
> Nope, that's `if (DEBUG_LOCKS_WARN_ON(!class))'
>=20
> 3106 static int match_held_lock(struct held_lock *hlock, struct lockdep_m=
ap *lock)
> 3107 {                                                                   =
                                                                           =
                                                                           =
   =20
> 3108     if (hlock->instance =3D=3D lock)
> 3109         return 1;
> 3110=20
> 3111     if (hlock->references) {
> 3112         struct lock_class *class =3D lock->class_cache[0];
> 3113=20
> 3114         if (!class)
> 3115             class =3D look_up_lock_class(lock, 0);
> 3116=20
> 3117         if (DEBUG_LOCKS_WARN_ON(!class))
> 3118             return 0;
> 3119=20
> 3120         if (DEBUG_LOCKS_WARN_ON(!hlock->nest_lock))
> 3121             return 0;
> 3122=20
> 3123         if (hlock->class_idx =3D=3D class - lock_classes + 1)
> 3124             return 1;
> 3125     }
> 3126=20
> 3127     return 0;
> 3128 }
> 3129=20

Ah, in that case my previous analysis was pointless and I shall need to
scratch my head some more.=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
