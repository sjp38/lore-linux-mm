Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id A9AE76B0112
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 19:02:37 -0500 (EST)
Received: by qadz32 with SMTP id z32so4213544qad.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 16:02:36 -0800 (PST)
Date: Tue, 21 Feb 2012 01:02:30 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120221000225.GJ5752@somewhere.redhat.com>
References: <4F2AC69B.7000704@redhat.com>
 <20120202175155.GV2518@linux.vnet.ibm.com>
 <4F2E7311.8060808@redhat.com>
 <20120205165927.GH2467@linux.vnet.ibm.com>
 <20120209152155.GA22552@somewhere.redhat.com>
 <4F33EEB3.4080807@redhat.com>
 <20120209182216.GG22552@somewhere.redhat.com>
 <20120209234144.GC2458@linux.vnet.ibm.com>
 <20120210013911.GM22552@somewhere.redhat.com>
 <4F3A5F0B.2090309@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F3A5F0B.2090309@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Tue, Feb 14, 2012 at 03:18:03PM +0200, Avi Kivity wrote:
> On 02/10/2012 03:39 AM, Frederic Weisbecker wrote:
> > > 
> > > As long as the code doesn't enter RCU read-side critical sections in
> > > the time between rcu_idle_enter() and rcu_idle_exit(), this should
> > > work fine.
> >
> > This should work fine yeah but further the correctness, I wonder if this
> > is going to be a win.
> >
> > We use rcu_idle_enter() in idle to avoid to keep the tick for RCU. But
> > what about falling into guest mode? I guess the tick is kept there
> > so is it going to be a win in throughput or something to use rcu_idle_enter()?
> 
> We could disable the tick while in guest mode as well.  Interrupts in
> guest mode are even more expensive than interrupts in user mode.

Right, that's definitely something I need to explore with the adaptive tickless
thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
