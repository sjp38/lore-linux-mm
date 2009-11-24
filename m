Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AE0FB6B0062
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 11:33:35 -0500 (EST)
Subject: Re: lockdep complaints in slab allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <4B0ADEF5.9040001@cs.helsinki.fi>
References: <20091118181202.GA12180@linux.vnet.ibm.com>
	 <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258709153.11284.429.camel@laptop>
	 <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>
	 <1258714328.11284.522.camel@laptop>  <4B067816.6070304@cs.helsinki.fi>
	 <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop>
	 <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 24 Nov 2009 17:33:26 +0100
Message-ID: <1259080406.4531.1645.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, cl@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-23 at 21:13 +0200, Pekka Enberg wrote:
> Matt Mackall wrote:
> > This seems like a lot of work to paper over a lockdep false positive in
> > code that should be firmly in the maintenance end of its lifecycle? I'd
> > rather the fix or papering over happen in lockdep.
> 
> True that. Is __raw_spin_lock() out of question, Peter?-) Passing the 
> state is pretty invasive because of the kmem_cache_free() call in 
> slab_destroy(). We re-enter the slab allocator from the outer edges 
> which makes spin_lock_nested() very inconvenient.

I'm perfectly fine with letting the thing be as it is, its apparently
not something that triggers very often, and since slab will be killed
off soon, who cares.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
