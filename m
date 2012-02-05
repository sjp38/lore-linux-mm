Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 975C06B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 07:17:05 -0500 (EST)
Message-ID: <4F2E7311.8060808@redhat.com>
Date: Sun, 05 Feb 2012 14:16:17 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
References: <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com> <1328117722.2446.262.camel@twins> <20120201184045.GG2382@linux.vnet.ibm.com> <alpine.DEB.2.00.1202011404500.2074@router.home> <20120201201336.GI2382@linux.vnet.ibm.com> <4F2A58A1.90800@redhat.com> <20120202153437.GD2518@linux.vnet.ibm.com> <4F2AB66C.2030309@redhat.com> <20120202170134.GM2518@linux.vnet.ibm.com> <4F2AC69B.7000704@redhat.com> <20120202175155.GV2518@linux.vnet.ibm.com>
In-Reply-To: <20120202175155.GV2518@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Christoph Lameter <cl@linux.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On 02/02/2012 07:51 PM, Paul E. McKenney wrote:
> On Thu, Feb 02, 2012 at 07:23:39PM +0200, Avi Kivity wrote:
> > On 02/02/2012 07:01 PM, Paul E. McKenney wrote:
> > > > 
> > > > It's not called (since the cpu is not idle).  Instead we call
> > > > rcu_virt_note_context_switch().
> > >
> > > Frederic's work checks to see if there is only one runnable user task
> > > on a given CPU.  If there is only one, then the scheduling-clock interrupt
> > > is turned off for that CPU, and RCU is told to ignore it while it is
> > > executing in user space.  Not sure whether this covers KVM guests.
> > 
> > Conceptually it's the same.  Maybe it needs adjustments, since kvm
> > enters a guest in a different way than the kernel exits to userspace.
> > 
> > > In any case, this is not yet in mainline.
> > 
> > Let me know when it's in, and I'll have a look.
>
> Could you please touch base with Frederic Weisbecker to make sure that
> what he is doing works for you?
>

Looks like there are new rcu_user_enter() and rcu_user_exit() APIs which
we can use.  Hopefully they subsume rcu_virt_note_context_switch() so we
only need one set of APIs.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
