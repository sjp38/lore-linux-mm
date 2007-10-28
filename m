Date: Sun, 28 Oct 2007 15:10:03 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 04/10] SLUB: Avoid checking for a valid object before
 zeroing on the fast path
In-Reply-To: <20071028033259.263401839@sgi.com>
Message-ID: <Pine.LNX.4.64.0710281509510.6766@sbz-30.cs.Helsinki.FI>
References: <20071028033156.022983073@sgi.com> <20071028033259.263401839@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Oct 2007, Christoph Lameter wrote:
> The fast path always results in a valid object. Move the check
> for the NULL pointer to the slow branch that calls
> __slab_alloc. Only __slab_alloc can return NULL if there is no
> memory available anymore and that case is exceedingly rare.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
