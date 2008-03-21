Date: Fri, 21 Mar 2008 10:40:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on
 IA64 and x86
In-Reply-To: <20080321.002502.223136918.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061726.782068299@sgi.com>
 <20080321.002502.223136918.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Mar 2008, David Miller wrote:

> I would be very careful with this especially on IA64.
> 
> If the TLB miss or other low-level trap handler depends upon being
> able to dereference thread info, task struct, or kernel stack stuff
> without causing a fault outside of the linear PAGE_OFFSET area, this
> patch will cause problems.

Hmmm. Does not sound good for arches that cannot handle TLB misses in 
hardware. I wonder how arch specific this is? Last time around I was told 
that some arches already virtually map their stacks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
