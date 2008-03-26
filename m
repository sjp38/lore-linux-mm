Date: Wed, 26 Mar 2008 16:21:43 -0700 (PDT)
Message-Id: <20080326.162143.244048620.davem@davemloft.net>
Subject: Re: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0803261052550.29859@schroedinger.engr.sgi.com>
References: <87wsnrgg9q.fsf@basil.nowhere.org>
	<18409.56843.909298.717089@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.64.0803261052550.29859@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 26 Mar 2008 10:56:17 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: paulus@samba.org, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> One should emphasize that this test was a kernel compile which is not 
> a load that gains much from larger pages.

Actually, ever since gcc went to a garbage collecting allocator, I've
found it to be a TLB thrasher.

It will repeatedly randomly walk over a GC pool of at least 8MB in
size, which to fit fully in the TLB with 4K pages reaquires a TLB with
2048 entries assuming gcc touches no other data which is of course a
false assumption.

For some compiles this GC pool is more than 100MB in size.

GCC does not fit into any modern TLB using it's base page size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
