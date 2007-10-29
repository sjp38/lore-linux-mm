Date: Sun, 28 Oct 2007 20:34:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 08/10] SLUB: Optional fast path using cmpxchg_local
In-Reply-To: <Pine.LNX.4.64.0710281502480.4207@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0710282031060.28860@schroedinger.engr.sgi.com>
References: <20071028033156.022983073@sgi.com> <20071028033300.240703208@sgi.com>
 <Pine.LNX.4.64.0710281502480.4207@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Oct 2007, Pekka J Enberg wrote:

> -	local_irq_restore(flags);
> +	object = do_slab_alloc(s, c, gfpflags, node, addr);
> +	if (unlikely(!object))
> +		goto out;

Undoing the optimization that one of the earlier patches added.

The #ifdef version is for me at least easier to read. The code there is a 
special unit that has to deal with the most performance critical piece of 
the slab allocator. And the #ifdef there clarifies that any changes have 
to be done to both branches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
