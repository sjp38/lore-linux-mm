Date: Fri, 21 Mar 2008 12:04:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on
 IA64 and x86
In-Reply-To: <20080321190258.GF6571@elte.hu>
Message-ID: <Pine.LNX.4.64.0803211201530.19432@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061726.782068299@sgi.com>
 <20080321.002502.223136918.davem@davemloft.net> <20080321083952.GA20454@elte.hu>
 <Pine.LNX.4.64.0803211032390.18671@schroedinger.engr.sgi.com>
 <20080321190258.GF6571@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Mar 2008, Ingo Molnar wrote:

> your patch indeed does not introduce it here, but 
> KERNEL_STACK_SIZE_ORDER shows up in the x86 portion of your patch and 
> you refer to multi-order stack allocations in your 0/14 mail :-)

Ahh. I see. Remnants from V2 in IA64 code. That portion has to be removed 
because of the software TLB issues on IA64 as pointed out by Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
