Date: Thu, 12 Aug 1999 10:41:35 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: vremap question
In-Reply-To: <199908121419.QAA16816@sphinx.cs.tu-berlin.de>
Message-ID: <Pine.LNX.3.96.990812103330.17129A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gilles Pokam <pokam@cs.tu-berlin.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Aug 1999, Gilles Pokam wrote:

> Are there some restrictions on the use of vremap ?
> 
> I am trying to map 1MB of my PCI-device memory into kernel space. Having the base
> i/o address and the span of my device memory i use the ioremap function like this:
>  virt = ioremap_nocache(base_io,size);

That sounds right so long as your base address and size are page aligned.

> my device memory is subdivided like this: 216kb of unused memory,216kb of prom,128kb 
> register,128kb fpga and 216kb of sram. After the ioremap call, i can access the prom
> region, but any attempt to read or write the sram,register or fpga region yields 0x0!
> 
> can someone tell me what is wrong ?

If ioremap returned non-NULL, then it is successful.  Are you certain
about the memory mapping?  If this sounds like a new piece of hardware, I
wouldn't bet the farm on it working properly at all.  The fact that you're
reading 0's means that something is responding on the bus, but that
doesn't mean the timing is right -- one device I worked on would randomly
report 0s or garbage on reads of large blocks until the FPGA code was
right.

		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
