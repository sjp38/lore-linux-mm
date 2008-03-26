MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18409.56843.909298.717089@cargo.ozlabs.ibm.com>
Date: Wed, 26 Mar 2008 16:24:27 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: larger default page sizes...
In-Reply-To: <87wsnrgg9q.fsf@basil.nowhere.org>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
	<20080321.145712.198736315.davem@davemloft.net>
	<Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
	<20080324.133722.38645342.davem@davemloft.net>
	<18408.29107.709577.374424@cargo.ozlabs.ibm.com>
	<87wsnrgg9q.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: David Miller <davem@davemloft.net>, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Andi Kleen writes:

> Paul Mackerras <paulus@samba.org> writes:
> > 
> > 4kB pages:	444.051s user + 34.406s system time
> > 64kB pages:	419.963s user + 16.869s system time
> > 
> > That's nearly 10% faster with 64kB pages -- on a kernel compile.
> 
> Do you have some idea where the improvement mainly comes from?
> Is it TLB misses or reduced in kernel overhead? Ok I assume both
> play together but which part of the equation is more important?

With the kernel configured for a 64k page size, but using 4k pages in
the hardware page table, I get:

64k/4k: 441.723s user + 27.258s system time

So the improvement in the user time is almost all due to the reduced
TLB misses (as one would expect).  For the system time, using 64k
pages in the VM reduces it by about 21%, and using 64k hardware pages
reduces it by another 30%.  So the reduction in kernel overhead is
significant but not as large as the impact of reducing TLB misses.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
