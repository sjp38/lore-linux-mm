Return-Path: <owner-linux-mm@kvack.org>
Date: Sun, 14 Dec 2008 19:51:47 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [rfc][patch] SLQB slab allocator
In-Reply-To: <84144f020812130103t11fb4054rb934376a034ec802@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0812141950210.3237@quilx.com>
References: <20081212002518.GH8294@wotan.suse.de>  <Pine.LNX.4.64.0812122013390.15781@quilx.com>
 <84144f020812130103t11fb4054rb934376a034ec802@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, bcrl@kvack.org, list-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Dec 2008, Pekka Enberg wrote:

> Lets not forget the order-0 page thing, which is nice from page
> allocator fragmentation point of view. But I suppose SLUB can use them
> as well if we get around fixing the page allocator fastpaths?

If the fastpath of the page allocator would be comparable in performance
to the slab allocators then page sized allocations could simply be
forwarded to the page allocator etc. IMHO this is how it should be ....
Right now slab allocators must buffer PAGE_SIZEd allocs due to page
allocator slowness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
