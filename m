Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B75346B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 15:06:13 -0500 (EST)
Date: Wed, 1 Feb 2012 14:06:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
In-Reply-To: <20120201184045.GG2382@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1202011404500.2074@router.home>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com> <1327591185.2446.102.camel@twins> <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com> <1328117722.2446.262.camel@twins> <20120201184045.GG2382@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Wed, 1 Feb 2012, Paul E. McKenney wrote:

> On Wed, Feb 01, 2012 at 06:35:22PM +0100, Peter Zijlstra wrote:
> > On Sun, 2012-01-29 at 10:25 +0200, Gilad Ben-Yossef wrote:
> > >
> > > If this is of interest, I keep a list tracking global IPI and global
> > > task schedulers sources in the core kernel here:
> > > https://github.com/gby/linux/wiki.
> >
> > You can add synchronize_.*_expedited() to the list, it does its best to
> > bash the entire machine in order to try and make RCU grace periods
> > happen fast.
>
> I have duly added "Make synchronize_sched_expedited() avoid IPIing idle
> CPUs" to http://kernel.org/pub/linux/kernel/people/paulmck/rcutodo.html.
>
> This should not be hard once I have built up some trust in the new
> RCU idle-detection code.  It would also automatically apply to
> Frederic's dyntick-idle userspace work.

Could we also apply the same approach to processors busy doing
computational work? In that case the OS is also not needed. Interrupting
these activities is impacting on performance and latency.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
