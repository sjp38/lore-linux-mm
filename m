Date: Fri, 18 May 2007 16:42:10 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] increase struct page size?!
In-Reply-To: <20070518040854.GA15654@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705181633240.24071@blonde.wat.veritas.com>
References: <20070518040854.GA15654@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007, Nick Piggin wrote:
> 
> If we add 8 bytes to struct page on 64-bit machines, it becomes 64 bytes,
> which is quite a nice number for cache purposes.
> 
> However we don't have to let those 8 bytes go to waste: we can use them
> to store the virtual address of the page, which kind of makes sense for
> 64-bit, because they can likely to use complicated memory models.

Sooner rather than later, don't we need those 8 bytes to expand from
atomic_t to atomic64_t _count and _mapcount?  Not that we really need
all 64 bits of both, but I don't know how to work atomically with less.

(Why do I have this sneaking feeling that you're actually wanting
to stick something into the lower bits of page->virtual?)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
