Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 1A5B16B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:21:51 -0400 (EDT)
Date: Mon, 30 Jul 2012 20:21:40 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120730192140.GU25459@jl-vm1.vm.bytemark.co.uk>
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
 <20120725175628.GH2378@linux.vnet.ibm.com>
 <alpine.LSU.2.00.1207251313180.1942@eggly.anvils>
 <20120725211217.GR2378@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120725211217.GR2378@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Paul E. McKenney wrote:
> > Does some version of gcc, under the options which we insist upon,
> > make such optimizations on any of the architectures which we support?
> 
> Pretty much any production-quality compiler will do double-fetch
> and old-value-reuse optimizations, the former especially on 32-bit
> x86.  I don't know of any production-quality compilers that do value
> speculation, which would make the compiler act like DEC Alpha hardware,
> and I would hope that if this does appear, (1) we would have warning
> and (2) it could be turned off.  But there has been a lot of work on
> this topic, so we would be foolish to rule it out.

GCC documentation for IA-64:

   -msched-ar-data-spec
   -mno-sched-ar-data-spec
     (En/Dis)able data speculative scheduling after reload. This results
     in generation of ld.a instructions and the corresponding check
     instructions (ld.c / chk.a). The default is 'enable'.

I don't know if that results in value speculation of the relevant kind.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
