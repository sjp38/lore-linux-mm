Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 8B9AC6B13F3
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 11:15:22 -0500 (EST)
Message-ID: <4F2AB66C.2030309@redhat.com>
Date: Thu, 02 Feb 2012 18:14:36 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com> <1327591185.2446.102.camel@twins> <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com> <1328117722.2446.262.camel@twins> <20120201184045.GG2382@linux.vnet.ibm.com> <alpine.DEB.2.00.1202011404500.2074@router.home> <20120201201336.GI2382@linux.vnet.ibm.com> <4F2A58A1.90800@redhat.com> <20120202153437.GD2518@linux.vnet.ibm.com>
In-Reply-To: <20120202153437.GD2518@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Christoph Lameter <cl@linux.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On 02/02/2012 05:34 PM, Paul E. McKenney wrote:
> On Thu, Feb 02, 2012 at 11:34:25AM +0200, Avi Kivity wrote:
> > On 02/01/2012 10:13 PM, Paul E. McKenney wrote:
> > > > 
> > > > Could we also apply the same approach to processors busy doing
> > > > computational work? In that case the OS is also not needed. Interrupting
> > > > these activities is impacting on performance and latency.
> > >
> > > Yep, that is in fact what Frederic's dyntick-idle userspace work does.
> > 
> > Running in a guest is a special case of running in userspace, so we'd
> > need to extend this work to kvm as well.
>
> As long as rcu_idle_enter() is called at the appropriate time, RCU will
> happily ignore the CPU.  ;-)
>

It's not called (since the cpu is not idle).  Instead we call
rcu_virt_note_context_switch().

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
