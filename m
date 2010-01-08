Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EEDB86B0044
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 14:12:35 -0500 (EST)
Date: Fri, 8 Jan 2010 11:11:32 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.DEB.2.00.1001081255100.26886@router.home>
Message-ID: <alpine.LFD.2.00.1001081102120.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com> <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
 <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain> <20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>
 <20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001051917000.3630@localhost.localdomain> <20100106125625.b02c1b3a.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain> <1262969610.4244.36.camel@laptop>
 <alpine.LFD.2.00.1001080911340.7821@localhost.localdomain> <alpine.DEB.2.00.1001081138260.23727@router.home> <87my0omo3n.fsf@basil.nowhere.org> <alpine.DEB.2.00.1001081255100.26886@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Fri, 8 Jan 2010, Christoph Lameter wrote:

> On Fri, 8 Jan 2010, Andi Kleen wrote:
> 
> > This year's standard server will be more like 24-64 "cpus"
> 
> What will it be? 2 or 4 sockets?

I think we can be pretty safe in saying that two sockets is going to be 
overwhelmingly the more common case.

It's simply physics and form factor. It's hard to put four powerful CPU's 
on one board in any normal form-factor, so when you go from 2->4 sockets, 
you almost inevitably have to go to rather fancier form-factors (or 
low-power sockets designed for socket-density rather than multi-core 
density, which is kind of against the point these days).

So often you end up with CPU daughter-cards etc, which involves a lot more 
design and cost, and no longer fit in standard desktop enclosures for 
people who want stand-alone servers etc (or even in rack setups if you 
want local disks too etc).

Think about it this way: just four sockets and associated per-socket RAM 
DIMM's (never mind anything else) take up a _lot_ of space. And you can 
only make your boards so big before they start having purely machanical 
issues due to flexing etc.

Which is why I suspect that two sockets will be the bulk of the server 
space for the forseeable future. It's been true before, and multiple 
memory channels per socket to feed all those cores are just making it even 
more so.

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
