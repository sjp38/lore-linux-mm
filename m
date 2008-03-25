Date: Tue, 25 Mar 2008 10:42:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [11/14] vcompound: Fallbacks for order 1 stack allocations on
 IA64 and x86
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE5B84D@orsmsx424.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0803251036410.15870@schroedinger.engr.sgi.com>
References: <20080321061726.782068299@sgi.com> <20080321.002502.223136918.davem@davemloft.net>
 <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
 <20080321.145712.198736315.davem@davemloft.net>
 <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
 <1FE6DD409037234FAB833C420AA843ECE5B84D@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Mar 2008, Luck, Tony wrote:

> > I am familiar with that area and I am resonably sure that this 
> > is an issue on IA64 under some conditions (the processor decides to spill 
> > some registers either onto the stack or into the register backing store 
> > during tlb processing). Recursion (in the kernel context) still expects 
> > the stack and register backing store to be available. ccing linux-ia64 for 
> > any thoughts to the contrary.
> 
> Christoph is correct ... IA64 pins the TLB entry for the kernel stack
> (which covers both the normal C stack and the register backing store)
> so that it won't have to deal with a TLB miss on the stack while handling
> another TLB miss.

I thought the only pinned TLB entry was for the per cpu area? How does it 
pin the TLB? The expectation is that a single TLB covers the complete 
stack area? Is that a feature of fault handling?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
