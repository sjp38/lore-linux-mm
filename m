Date: Mon, 24 Mar 2008 11:27:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on
 IA64 and x86
In-Reply-To: <20080321.145712.198736315.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
References: <20080321061726.782068299@sgi.com> <20080321.002502.223136918.davem@davemloft.net>
 <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
 <20080321.145712.198736315.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Mar 2008, David Miller wrote:

> The thing to do is to first validate the way that IA64
> handles recursive TLB misses occuring during an initial
> TLB miss, and if there are any limitations therein.

I am familiar with that area and I am resonably sure that this 
is an issue on IA64 under some conditions (the processor decides to spill 
some registers either onto the stack or into the register backing store 
during tlb processing). Recursion (in the kernel context) still expects 
the stack and register backing store to be available. ccing linux-ia64 for 
any thoughts to the contrary.

The move to 64k page size on IA64 is another way that this issue can be 
addressed though. So I think its best to drop the IA64 portion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
