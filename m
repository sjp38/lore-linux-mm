Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4B94A6B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:53:40 -0500 (EST)
Date: Tue, 24 Nov 2009 12:53:26 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: lockdep complaints in slab allocator
In-Reply-To: <1259087511.4531.1775.camel@laptop>
Message-ID: <alpine.DEB.2.00.0911241245140.14045@router.home>
References: <1258714328.11284.522.camel@laptop>  <4B067816.6070304@cs.helsinki.fi> <1258729748.4104.223.camel@laptop>  <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx>  <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop>
  <20091124170032.GC6831@linux.vnet.ibm.com>  <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop>  <20091124182506.GG6831@linux.vnet.ibm.com> <1259087511.4531.1775.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009, Peter Zijlstra wrote:

> On Tue, 2009-11-24 at 10:25 -0800, Paul E. McKenney wrote:
>
> > Well, I suppose I could make my scripts randomly choose the memory
> > allocator, but I would rather not.  ;-)
>
> Which is why I hope we'll soon be down to 2, SLOB for tiny systems and
> SLQB for the rest of us, having 3 in-tree and 1 pending is pure and
> simple insanity.
>
> Preferably SLQB will be small enough to also be able to get rid of SLOB,
> but I've not recently seen any data on that particular issue.

We have some issues with NUMA in SLQB. Memoryless node support needs to
get some work. The fixes of memoryless node support to SLAB by Lee
create another case where SLQB will be regressing against SLAB.

Multiple modifications of per cpu variables in allocators other than SLUB
means that interruptless fastpath is going to be difficult to realize and
may continue to cause rt issues with preemption and per cpu handling.

Memory consumption of SLQB is better??





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
