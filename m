Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 695826B0044
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 12:27:06 -0500 (EST)
Date: Fri, 27 Nov 2009 11:26:54 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: lockdep complaints in slab allocator
In-Reply-To: <84144f020911241307u14cd2cf0h614827137e42378e@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.0911271123220.20368@router.home>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>  <1258729748.4104.223.camel@laptop>  <1259002800.5630.1.camel@penberg-laptop>  <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi>  <1259080406.4531.1645.camel@laptop>
  <20091124170032.GC6831@linux.vnet.ibm.com>  <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop>  <1259090615.17871.696.camel@calx> <84144f020911241307u14cd2cf0h614827137e42378e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, Peter Zijlstra <peterz@infradead.org>, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009, Pekka Enberg wrote:

> Yeah, something like that. I don't think we were really able to decide
> anything at the KS. IIRC Christoph was in favor of having multiple
> slab allocators in the tree whereas I, for example, would rather have
> only one. The SLOB allocator is bit special here because it's for
> embedded. However, I also talked to some embedded folks at the summit
> and none of them were using SLOB because the gains weren't big enough.
> So I don't know if it's being used that widely.

Are there any current numbers on SLOB memory advantage vs the other
allcoators?

> I personally was hoping for SLUB or SLQB to emerge as a clear winner
> so we could delete the rest but that hasn't really happened.

I think having multiple allocators makes for a heathly competition between
them and stabillizes the allocator API. Frankly I would like to see more
exchangable subsystems in the core. The scheduler seems to be not
competitive for my current workloads running on 2.6.22 (we have not tried
2.6.32 yet) and I have a lot of concerns about the continual performance
deteriorations in the page allocator and the reclaim logic due to feature
bloat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
