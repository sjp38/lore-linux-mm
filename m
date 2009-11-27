Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 26A556B0044
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 12:28:36 -0500 (EST)
Date: Fri, 27 Nov 2009 11:28:22 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: lockdep complaints in slab allocator
In-Reply-To: <alpine.DEB.2.00.0911251356130.11347@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.0911271127130.20368@router.home>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com> <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop>
 <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop> <1259090615.17871.696.camel@calx> <84144f020911241307u14cd2cf0h614827137e42378e@mail.gmail.com> <1259103315.17871.895.camel@calx>
 <alpine.DEB.2.00.0911251356130.11347@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 2009, David Rientjes wrote:

> On Tue, 24 Nov 2009, Matt Mackall wrote:
>
> > I'm afraid I have only anecdotal reports from SLOB users, and embedded
> > folks are notorious for lack of feedback, but I only need a few people
> > to tell me they're shipping 100k units/mo to be confident that SLOB is
> > in use in millions of devices.
> >
>
> It's much more popular than I had expected; do you think it would be
> possible to merge slob's core into another allocator or will it require
> seperation forever?

It would be possible to create a slab-common.c and isolate common handling
of all allocators. SLUB and SLQB share quite a lot of code and SLAB could
be cleaned up and made to fit into such a framework.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
