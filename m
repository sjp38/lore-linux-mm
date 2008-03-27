MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18411.3504.486805.813472@cargo.ozlabs.ibm.com>
Date: Thu, 27 Mar 2008 14:00:00 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: larger default page sizes...
In-Reply-To: <Pine.LNX.4.64.0803261052550.29859@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
	<20080321.145712.198736315.davem@davemloft.net>
	<Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
	<20080324.133722.38645342.davem@davemloft.net>
	<18408.29107.709577.374424@cargo.ozlabs.ibm.com>
	<87wsnrgg9q.fsf@basil.nowhere.org>
	<18409.56843.909298.717089@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.64.0803261052550.29859@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter writes:

> One should emphasize that this test was a kernel compile which is not 
> a load that gains much from larger pages. 4k pages are mostly okay for 
> loads that use large amounts of small files.

It's also worth emphasizing that 1.5% of the total time, or 21% of the
system time, is pure software overhead in the Linux kernel that has
nothing to do with the TLB or with gcc's memory access patterns.

That's the cost of handling memory in small (i.e. 4kB) chunks inside
the generic Linux VM code, rather than bigger chunks.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
