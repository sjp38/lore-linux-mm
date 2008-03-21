Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on IA64 and x86
References: <20080321061703.921169367@sgi.com>
	<20080321061726.782068299@sgi.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 21 Mar 2008 23:30:54 +0100
In-Reply-To: <20080321061726.782068299@sgi.com>
Message-ID: <871w63iuap.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> writes:

> This allows fallback for order 1 stack allocations. In the fallback
> scenario the stacks will be virtually mapped.

The traditional reason this was discouraged (people seem to reinvent
variants of this patch all the time) was that there used 
to be drivers that did __pa() (or equivalent) on stack addresses
and that doesn't work with vmalloc pages.

I don't know if such drivers still exist, but such a change
is certainly not a no-brainer

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
