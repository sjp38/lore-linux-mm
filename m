Message-ID: <3CD9A7FA.5967F675@linux-m68k.org>
Date: Thu, 09 May 2002 00:34:34 +0200
From: Roman Zippel <zippel@linux-m68k.org>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap 13a
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

William Lee Irwin III wrote:

> A:
> static inline void *page_address(struct page *page)
> {
>         return __va((page - mem_map) << PAGE_SHIFT);
> }

This is very broken.

> If table lookup is wanted, I feel that should also be a generic option.
> There is nothing inherently architecture-specific about using a table-
> driven method of calculating page_address().

Archs already do the kaddr->node lookup. Archs setup the virtual mapping
and the pgdat nodes, they know best how they are layed out. Why do you
want to generalize this?

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
