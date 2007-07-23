Date: Mon, 23 Jul 2007 11:37:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] add __GFP_ZERP to GFP_LEVEL_MASK
Message-Id: <20070723113712.c0ee29e5.akpm@linux-foundation.org>
In-Reply-To: <1185185020.8197.11.camel@twins>
References: <1185185020.8197.11.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007 12:03:40 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Daniel recently spotted that __GFP_ZERO is not (and has never been)
> part of GFP_LEVEL_MASK. I could not find a reason for this in the
> original patch: 3977971c7f09ce08ed1b8d7a67b2098eb732e4cd in the -bk
> tree.

It doesn't make a lot of sense to be passing __GFP_ZERO into slab
allocation functions.  It's not really for the caller to be telling slab
how it should arrange for its new memory to get zeroed.

And the caller of slab functions will need to zero the memory anyway,
because you don't know whether your new object came direct from the page
allocator or if it is recycled memory from a partial slab.

I have a feeling that we did support passing __GFP_ZERO into the slab
allocation functions for a while, but took it out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
