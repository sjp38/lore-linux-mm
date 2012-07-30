Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id AF0576B005A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 16:29:08 -0400 (EDT)
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 30 Jul 2012 16:29:06 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id A638E38C804A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 16:29:00 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6UKSx30290496
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 16:29:00 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6UKSw43006522
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 14:28:58 -0600
Date: Mon, 30 Jul 2012 13:28:57 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120730202857.GL2391@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
 <20120725175628.GH2378@linux.vnet.ibm.com>
 <alpine.LSU.2.00.1207251313180.1942@eggly.anvils>
 <20120725211217.GR2378@linux.vnet.ibm.com>
 <20120730192140.GU25459@jl-vm1.vm.bytemark.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120730192140.GU25459@jl-vm1.vm.bytemark.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 30, 2012 at 08:21:40PM +0100, Jamie Lokier wrote:
> Paul E. McKenney wrote:
> > > Does some version of gcc, under the options which we insist upon,
> > > make such optimizations on any of the architectures which we support?
> > 
> > Pretty much any production-quality compiler will do double-fetch
> > and old-value-reuse optimizations, the former especially on 32-bit
> > x86.  I don't know of any production-quality compilers that do value
> > speculation, which would make the compiler act like DEC Alpha hardware,
> > and I would hope that if this does appear, (1) we would have warning
> > and (2) it could be turned off.  But there has been a lot of work on
> > this topic, so we would be foolish to rule it out.
> 
> GCC documentation for IA-64:
> 
>    -msched-ar-data-spec
>    -mno-sched-ar-data-spec
>      (En/Dis)able data speculative scheduling after reload. This results
>      in generation of ld.a instructions and the corresponding check
>      instructions (ld.c / chk.a). The default is 'enable'.
> 
> I don't know if that results in value speculation of the relevant kind.

If I remember correctly, the chk.a instruction will detect failed
speculation via cache state and deal with the situation correctly,
but I really need to defer to someone with more recent IA-64 experience.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
