Message-ID: <3CDA6C8E.462A3AE5@linux-m68k.org>
Date: Thu, 09 May 2002 14:33:18 +0200
From: Roman Zippel <zippel@linux-m68k.org>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap 13a
References: <Pine.LNX.4.44L.0205062316490.32261-100000@imladris.surriel.com> <20020507183741.A25245@infradead.org> <3CD96CB1.4630ED48@linux-m68k.org> <20020508213452.GJ15756@holomorphy.com> <3CD9A7FA.5967F675@linux-m68k.org> <20020508224255.GM15756@holomorphy.com> <3CD9B42A.69D38522@linux-m68k.org> <20020509012929.GO15756@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

William Lee Irwin III wrote:

> > You should not only look at the i386 code, if you want to create generic
> > functions.
> 
> It's not only i386. Other architectures are able to do likewise if
> they satisfy the preconditions. And this is exactly one of four
> variations, where all four together are able to handle all cases.
> (In fact, just reverting to B works as a catch-all.)

Your preconditions were no CONFIG_DISCONTIGMEM and no CONFIG_HIGHMEM.
This is true for m68k, but it still breaks every single of your
assumptions, but even on other archs where do these preconditions
require physical memory to start at 0?

> There doesn't seem to be enough depth to this subject to merit this
> much discussion. Are we speaking at cross-purposes? Since I wrote a
> bit of this, is there an issue you're having you'd like me to address?
> I have a sun3 that's booted Linux in the past, so I might be able to
> reproduce m68k-specific issues that arise.

It's really not m68k specific. You are trying to generalize a very small
part of the whole problem. First you only take some special cases (A.
and B.) and the rest was completely arch specific so far. You have to
define the complete model of how virtual and physical addresses and the
pgdat/index tuple relate to each other, before you can generalize
something of it. So far it was completely up to the archs to define this
relationship with only little assumptions from the generic code.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
