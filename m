Message-ID: <3CD96CB1.4630ED48@linux-m68k.org>
Date: Wed, 08 May 2002 20:21:37 +0200
From: Roman Zippel <zippel@linux-m68k.org>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap 13a
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Christoph Hellwig wrote:

> >   - NUMA changes for page_address                         (Samuel Ortiz)
> 
> I don't think the changes makes sense.  If calculating page_address is
> complicated and slow enough to place it out-of-lin using page->virtual
> is much better.
> 
> I'd suggest backing this patch out and instead always maintain page->virtual
> for discontigmem.  While at this as a little cleanup you might want to
> define WANT_PAGE_VIRTUAL based on CONFIG_HIGHMEM || CONFIG_DISCONTIGMEM
> at the top of mm.h instead of cluttering it up.

I'd suggest, we move page_address to asm/page.h (as counterpart of
virt_to_page). discontigmem configs can then use some more efficient
table lookup. Other config usually want to implement it better as:

#define page_address(page)	((((page) - mem_map) << PAGE_SHIFT) +
PAGE_OFFSET)

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
