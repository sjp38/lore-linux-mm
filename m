Date: Wed, 8 May 2002 15:42:55 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020508224255.GM15756@holomorphy.com>
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3CD9A7FA.5967F675@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> A:
>> static inline void *page_address(struct page *page)
>> {
>>         return __va((page - mem_map) << PAGE_SHIFT);
>> }

On Thu, May 09, 2002 at 12:34:34AM +0200, Roman Zippel wrote:
> This is very broken.

I beg your pardon? AFAICT it's equivalent to the macro you yourself
posted.

include/asm-i386/page.h:133:#define __va(x)                     ((void *)((unsigned long)(x)+PAGE_OFFSET))

It makes only 3 assumptions:
(1) memory is contiguous
(2) memory starts from 0
(3) mem_map is in 1:1 order-preserving correspondence with phys pages


William Lee Irwin III wrote:
>> If table lookup is wanted, I feel that should also be a generic option.
>> There is nothing inherently architecture-specific about using a table-
>> driven method of calculating page_address().

On Thu, May 09, 2002 at 12:34:34AM +0200, Roman Zippel wrote:
> Archs already do the kaddr->node lookup. Archs setup the virtual mapping
> and the pgdat nodes, they know best how they are layed out. Why do you
> want to generalize this?

Because they were doing it before and they all duplicated each others' code.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
