Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EFE8460021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 17:41:54 -0500 (EST)
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id nB1MfnBH025649
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 22:41:50 GMT
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by zps18.corp.google.com with ESMTP id nB1MflpX026413
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 14:41:47 -0800
Received: by pwi6 with SMTP id 6so431pwi.7
        for <linux-mm@kvack.org>; Tue, 01 Dec 2009 14:41:47 -0800 (PST)
Date: Tue, 1 Dec 2009 14:41:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: lockdep complaints in slab allocator
In-Reply-To: <1259626875.29740.193.camel@calx>
Message-ID: <alpine.DEB.2.00.0912011436420.27500@chino.kir.corp.google.com>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com> <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop>
 <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop> <1259090615.17871.696.camel@calx> <84144f020911241307u14cd2cf0h614827137e42378e@mail.gmail.com> <1259103315.17871.895.camel@calx>
 <alpine.DEB.2.00.0911251356130.11347@chino.kir.corp.google.com> <alpine.DEB.2.00.0911271127130.20368@router.home> <alpine.DEB.2.00.0911301512250.12038@chino.kir.corp.google.com> <1259626875.29740.193.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Nov 2009, Matt Mackall wrote:

> And it's not even something that -most- of embedded devices will want to
> use, so it can't be keyed off CONFIG_EMBEDDED anyway. If you've got even
> 16MB of memory, you probably want to use a SLAB-like allocator (ie not
> SLOB). But there are -millions- of devices being shipped that don't have
> that much memory, a situation that's likely to continue until you can
> fit a larger Linux system entirely in a <$1 microcontroller-sized device
> (probably 5 years off still).
> 

What qualifying criteria can we use to automatically select slob for a 
kernel or the disqualifying criteria to automatically select slub as a 
default, then?  It currently depends on CONFIG_EMBEDDED, but it still 
requires the user to specifically chose the allocator over another.  Could 
we base this decision on another config option enabled for systems with 
less than 16MB?

> This thread is annoying. The problem that triggered this thread is not
> in SLOB/SLUB/SLQB, nor even in our bog-standard 10yo deep-maintenance
> known-to-work SLAB code. The problem was a FALSE POSITIVE from lockdep
> on code that PREDATES lockdep itself. There is nothing in this thread to
> indicate that there is a serious problem maintaining multiple
> allocators. In fact, considerably more time has been spent (as usual)
> debating non-existent problems than fixing real ones.
> 

We could move the discussion on the long-term maintainable aspects of 
multiple slab allocators to a new thread if you'd like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
