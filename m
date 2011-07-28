Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 092A06B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 06:52:10 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1QmOCE-0002Kg-VV
	for linux-mm@kvack.org; Thu, 28 Jul 2011 10:52:07 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QmOCE-0001Tg-Ez
	for linux-mm@kvack.org; Thu, 28 Jul 2011 10:52:06 +0000
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.DEB.2.00.1107281346060.2841@tiger>
References: <20110716211850.GA23917@breakpoint.cc>
	 <alpine.LFD.2.02.1107172333340.2702@ionos>
	 <alpine.DEB.2.00.1107201619540.3528@tiger> <1311168638.5345.80.camel@twins>
	 <alpine.DEB.2.00.1107201642500.4921@tiger>
	 <1311176680.29152.20.camel@twins>
	 <alpine.DEB.2.00.1107281346060.2841@tiger>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Jul 2011 12:56:39 +0200
Message-ID: <1311850599.2617.107.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sebastian Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Thu, 2011-07-28 at 13:46 +0300, Pekka Enberg wrote:
> On Wed, 20 Jul 2011, Peter Zijlstra wrote:
> > We just need to annotate the SLAB_DEBUG_OBJECTS slab with a different
> > key. Something like the below, except that doesn't quite cover cpu
> > hotplug yet I think.. /me pokes more
> >
> > Completely untested, hasn't even seen a compiler etc..
> 
> Ping? Did someone send me a patch I can apply?

I've queued a slightly updated patch for the lockdep tree. It should
hopefully hit -tip soonish.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
