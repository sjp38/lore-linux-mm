Date: Wed, 8 May 2002 18:29:29 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13a
Message-ID: <20020509012929.GO15756@holomorphy.com>
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org> <20020508224255.GM15756@holomorphy.com> <3CD9B42A.69D38522@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3CD9B42A.69D38522@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> I beg your pardon? AFAICT it's equivalent to the macro you yourself
>> posted.
>> include/asm-i386/page.h:133:#define __va(x)                     ((void *)((unsigned long)(x)+PAGE_OFFSET))
>> It makes only 3 assumptions:
>> (1) memory is contiguous
>> (2) memory starts from 0
>> (3) mem_map is in 1:1 order-preserving correspondence with phys pages

On Thu, May 09, 2002 at 01:26:34AM +0200, Roman Zippel wrote:
> You should not only look at the i386 code, if you want to create generic
> functions.

It's not only i386. Other architectures are able to do likewise if
they satisfy the preconditions. And this is exactly one of four
variations, where all four together are able to handle all cases.
(In fact, just reverting to B works as a catch-all.) I am aware that
there are architectures who do not direct-map physical to virtual
within zones and they should either retain ->virtual or implement
UNMAP_NR_DENSE().


William Lee Irwin III wrote:
>> Because they were doing it before and they all duplicated each others' code.

On Thu, May 09, 2002 at 12:34:34AM +0200, Roman Zippel wrote:
> Table lookups can only be optimized if you know the memory layout and
> only the archs know that.
> Only the code for the simple case was copied.

The VM should informed of the memory layout by properly initialized
data structures...

There doesn't seem to be enough depth to this subject to merit this
much discussion. Are we speaking at cross-purposes? Since I wrote a
bit of this, is there an issue you're having you'd like me to address?
I have a sun3 that's booted Linux in the past, so I might be able to
reproduce m68k-specific issues that arise.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
