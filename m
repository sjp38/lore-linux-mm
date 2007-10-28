Date: Sun, 28 Oct 2007 17:14:12 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 09/10] SLUB: Do our own locking via slab_lock and
 slab_unlock.
In-Reply-To: <Pine.LNX.4.64.0710281702140.6766@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0710281713020.6766@sbz-30.cs.Helsinki.FI>
References: <20071028033156.022983073@sgi.com> <20071028033300.479692380@sgi.com>
 <Pine.LNX.4.64.0710281702140.6766@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Oct 2007, Pekka J Enberg wrote:
> > +	 __release(bitlock);
> 
> This needs a less generic name and maybe a comment explaining that it's 
> not annotating a proper lock? Or maybe we can drop it completely?

Ah, I see that <linux/bit_spinlock.h> does the same thing, so strike that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
