Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 297DF600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 18:14:30 -0500 (EST)
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id nAUNERfd013588
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:14:27 -0800
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by zps19.corp.google.com with ESMTP id nAUNDAOI019547
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:14:24 -0800
Received: by pxi10 with SMTP id 10so3420569pxi.33
        for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:14:24 -0800 (PST)
Date: Mon, 30 Nov 2009 15:14:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: lockdep complaints in slab allocator
In-Reply-To: <alpine.DEB.2.00.0911271127130.20368@router.home>
Message-ID: <alpine.DEB.2.00.0911301512250.12038@chino.kir.corp.google.com>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com> <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop>
 <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop> <1259090615.17871.696.camel@calx> <84144f020911241307u14cd2cf0h614827137e42378e@mail.gmail.com> <1259103315.17871.895.camel@calx>
 <alpine.DEB.2.00.0911251356130.11347@chino.kir.corp.google.com> <alpine.DEB.2.00.0911271127130.20368@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Nov 2009, Christoph Lameter wrote:

> > > I'm afraid I have only anecdotal reports from SLOB users, and embedded
> > > folks are notorious for lack of feedback, but I only need a few people
> > > to tell me they're shipping 100k units/mo to be confident that SLOB is
> > > in use in millions of devices.
> > >
> >
> > It's much more popular than I had expected; do you think it would be
> > possible to merge slob's core into another allocator or will it require
> > seperation forever?
> 
> It would be possible to create a slab-common.c and isolate common handling
> of all allocators. SLUB and SLQB share quite a lot of code and SLAB could
> be cleaned up and made to fit into such a framework.
> 

Right, but the user is still left with a decision of which slab allocator 
to compile into their kernel, each with distinct advantages and 
disadvantages that get exploited for the wide range of workloads that it 
runs.  If slob could be merged into another allocator, it would be simple 
to remove the distinction of it being seperate altogether, the differences 
would depend on CONFIG_EMBEDDED instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
