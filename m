Message-ID: <3CDC241B.A2CB4769@linux-m68k.org>
Date: Fri, 10 May 2002 21:48:43 +0200
From: Roman Zippel <zippel@linux-m68k.org>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap 13a
References: <20020509231309.GR15756@holomorphy.com> <Pine.LNX.4.21.0205101324260.32715-100000@serv> <20020510162824.GV15756@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Samuel Ortiz <sortiz@dbear.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

William Lee Irwin III wrote:

> > Mapping everything into a single virtual area, so that the virtual address
> > can be used as a index in the memmap array, e.g.
> > #define virt_to_page(kaddr)   (mem_map + (((unsigned long)(kaddr)-PAGE_OFFSET) >> PAGE_SHIFT))
> > #define page_to_virt(page)    ((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
> 
> This appears to be calculating it from a physical address...

Why?

> > For the lookup function above this means it becomes:
> > TABLE(SHIFT_AND(addr, shift, mask)) + addr
> > so that every operation could be directly patched.
> 
> This is the most interesting part, and appears very easy to genericize;
> I can produce this in short order unless you have a particular interest
> in doing it yourself (or have a patch waiting in the wings already).

It obfuscates the thing more than it helps. Only very few machines
really need it to this extreme.

> Maybe I should turn the question around instead, so I understand your
> motivation better:
> Why are you trying to hide physical addresses from the VM?

Because it doesn't need it. The VM works mostly with the page structure
and converts that as needed. It doesn't need to know how it's done.
Currently there are only few dependencies here, which gives us much
flexibility. I'm just afraid that by your generalization you create some
new rules how something has to be implemented. Sometimes that is needed,
but we should only do this if we gain a real advantage from it and I
don't see any.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
