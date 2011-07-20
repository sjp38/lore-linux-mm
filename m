Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B2996B00EC
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 10:00:45 -0400 (EDT)
Date: Wed, 20 Jul 2011 09:00:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
In-Reply-To: <alpine.DEB.2.00.1107201642500.4921@tiger>
Message-ID: <alpine.DEB.2.00.1107200858351.32737@router.home>
References: <20110716211850.GA23917@breakpoint.cc>  <alpine.LFD.2.02.1107172333340.2702@ionos>  <alpine.DEB.2.00.1107201619540.3528@tiger> <1311168638.5345.80.camel@twins> <alpine.DEB.2.00.1107201642500.4921@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Sebastian Siewior <sebastian@breakpoint.cc>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Wed, 20 Jul 2011, Pekka Enberg wrote:

> So what exactly is the lockdep complaint above telling us? We're holding on to
> l3->list_lock in cache_flusharray() (kfree path) but somehow we now entered
> cache_alloc_refill() (kmalloc path!) and attempt to take the same lock or lock
> in the same class.
>
> I am confused. How can that happen?

I guess you need a slab with CFLGS_OFF_SLAB metadata management. Then slab
does some recursive things doing allocations and free for metadata while
allocating larger objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
