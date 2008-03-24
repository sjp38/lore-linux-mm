Date: Mon, 24 Mar 2008 12:53:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on
 IA64 and x86
In-Reply-To: <871w63iuap.fsf@basil.nowhere.org>
Message-ID: <Pine.LNX.4.64.0803241251360.4218@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061726.782068299@sgi.com>
 <871w63iuap.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Mar 2008, Andi Kleen wrote:

> The traditional reason this was discouraged (people seem to reinvent
> variants of this patch all the time) was that there used 
> to be drivers that did __pa() (or equivalent) on stack addresses
> and that doesn't work with vmalloc pages.
> 
> I don't know if such drivers still exist, but such a change
> is certainly not a no-brainer

I thought that had been cleaned up because some arches already have 
virtually mapped stacks? This could be debugged by testing with
CONFIG_VFALLBACK_ALWAYS set. Which results in a stack that is always 
vmalloc'ed and thus the driver should fail.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
