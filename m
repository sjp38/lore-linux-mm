Date: Wed, 8 May 2002 14:50:01 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020508215001.GK15756@holomorphy.com>
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3CD96CB1.4630ED48@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2002 at 08:21:37PM +0200, Roman Zippel wrote:
> I'd suggest, we move page_address to asm/page.h (as counterpart of
> virt_to_page). discontigmem configs can then use some more efficient
> table lookup. Other config usually want to implement it better as:
> #define page_address(page)	((((page) - mem_map) << PAGE_SHIFT) +
> PAGE_OFFSET)
> bye, Roman

Sorry, I missed the part about table lookup.

If table lookup is wanted, I feel that should also be a generic option.
There is nothing inherently architecture-specific about using a table-
driven method of calculating page_address().

But why isn't zone_table[] already an instance of such a table?

An annotated description of the generic version is:

/* the table lookup */    
zone = zone_table[page->flags >> ZONE_SHIFT]

     /* the phys offset of the table entry */
__va(zone->zone_start_paddr
         +
/* calculating the offset within the table region */   /* scaling the offset */
((page - zone->zone_mem_map)                                << PAGE_SHIFT))



Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
