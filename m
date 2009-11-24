Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C221E6B004D
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:55:12 -0500 (EST)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nAOIocHC026829
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:50:38 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAOIt0kv126214
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:55:00 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAOIt0ag014903
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:55:00 -0500
Date: Tue, 24 Nov 2009 10:54:59 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep complaints in slab allocator
Message-ID: <20091124185459.GH6831@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop> <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop> <20091124182506.GG6831@linux.vnet.ibm.com> <1259087511.4531.1775.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1259087511.4531.1775.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, cl@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 07:31:51PM +0100, Peter Zijlstra wrote:
> On Tue, 2009-11-24 at 10:25 -0800, Paul E. McKenney wrote:
> 
> > Well, I suppose I could make my scripts randomly choose the memory
> > allocator, but I would rather not.  ;-)
> 
> Which is why I hope we'll soon be down to 2, SLOB for tiny systems and
> SLQB for the rest of us, having 3 in-tree and 1 pending is pure and
> simple insanity.

So I should start specifying SLOB for my TINY_RCU tests, then.

> Preferably SLQB will be small enough to also be able to get rid of SLOB,
> but I've not recently seen any data on that particular issue.

Given the existence of TINY_RCU, I would look pretty funny if I insisted
on but a single implementation of core subsystems.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
