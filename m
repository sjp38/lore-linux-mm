Date: Sun, 28 Oct 2007 19:59:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 08/10] SLUB: Optional fast path using cmpxchg_local
In-Reply-To: <Pine.LNX.4.64.0710281502480.4207@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0710281957470.28636@schroedinger.engr.sgi.com>
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

> Can you please write a comment of the locking rules when cmpxchg_local() 
> is used? Looks as if we could push that local_irq_save() to slub_lock() 
> and local_irq_restore() to slub_unlock() and deal with the unused flags 
> variable for the non-CONFIG_FAST_CMPXCHG_LOCAL case with a macro, no?

Hmmmm... Maybe .. The locking rules are not changed at all by this patch. 
The cmpxchg_local is only used for the per cpu object list. The per cpu 
slabs are frozen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
