Date: Fri, 21 Mar 2008 00:25:02 -0700 (PDT)
Message-Id: <20080321.002502.223136918.davem@davemloft.net>
Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on
 IA64 and x86
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080321061726.782068299@sgi.com>
References: <20080321061703.921169367@sgi.com>
	<20080321061726.782068299@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 20 Mar 2008 23:17:14 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> This allows fallback for order 1 stack allocations. In the fallback
> scenario the stacks will be virtually mapped.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

I would be very careful with this especially on IA64.

If the TLB miss or other low-level trap handler depends upon being
able to dereference thread info, task struct, or kernel stack stuff
without causing a fault outside of the linear PAGE_OFFSET area, this
patch will cause problems.

It will be difficult to debug the kinds of crashes this will cause
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
