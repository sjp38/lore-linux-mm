Message-ID: <3CD9B42A.69D38522@linux-m68k.org>
Date: Thu, 09 May 2002 01:26:34 +0200
From: Roman Zippel <zippel@linux-m68k.org>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap 13a
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org> <20020508224255.GM15756@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

William Lee Irwin III wrote:

> > This is very broken.
> 
> I beg your pardon? AFAICT it's equivalent to the macro you yourself
> posted.
> 
> include/asm-i386/page.h:133:#define __va(x)                     ((void *)((unsigned long)(x)+PAGE_OFFSET))
> 
> It makes only 3 assumptions:
> (1) memory is contiguous
> (2) memory starts from 0
> (3) mem_map is in 1:1 order-preserving correspondence with phys pages

You should not only look at the i386 code, if you want to create generic
functions.

> On Thu, May 09, 2002 at 12:34:34AM +0200, Roman Zippel wrote:
> > Archs already do the kaddr->node lookup. Archs setup the virtual mapping
> > and the pgdat nodes, they know best how they are layed out. Why do you
> > want to generalize this?
> 
> Because they were doing it before and they all duplicated each others' code.

Table lookups can only be optimized if you know the memory layout and
only the archs know that.
Only the code for the simple case was copied.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
