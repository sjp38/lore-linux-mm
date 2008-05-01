Date: Thu, 1 May 2008 13:18:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/1] mm: add virt to phys debug
In-Reply-To: <1209669740-10493-1-git-send-email-jirislaby@gmail.com>
Message-ID: <Pine.LNX.4.64.0805011310390.9288@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0804281322510.31163@schroedinger.engr.sgi.com>
 <1209669740-10493-1-git-send-email-jirislaby@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Jeremy Fitzhardinge <jeremy@goop.org>, pageexec@freemail.hu, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, herbert@gondor.apana.org.au, penberg@cs.helsinki.fi, akpm@linux-foundation.org, linux-ext4@vger.kernel.org, paulmck@linux.vnet.ibm.com, rjw@sisk.pl, zdenek.kabelac@gmail.com, David Miller <davem@davemloft.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 1 May 2008, Jiri Slaby wrote:

> Christoph, was you able to compile this somehow? I had to move the code
> into ioremap along 64-bit variant to allow the checking.

The 64 bit piece works fine here and I used it for debugging the vmalloc 
work. Not sure about the 32 bit piece.

> A pacth which I created is attached, I've successfully tested it by this
> module:

Great! Someone else picks this up. You can probably do a more thorough 
job than I can.

> Add some (configurable) expensive sanity checking to catch wrong address
> translations on x86.
> 
> - create linux/mmdebug.h file to be able include this file in
>   asm headers to not get unsolvable loops in header files
> - __phys_addr on x86_32 became a function in ioremap.c since
>   PAGE_OFFSET and is_vmalloc_addr is undefined if declared in
>   page_32.h (again circular dependencies)
> - add __phys_addr_const for initializing doublefault_tss.__cr3

Hmmm.. We could use include/linux/bounds.h to make 
VMALLOC_START/VMALLOC_END (or whatever you need for checking the memory 
boundaries) a cpp constant which may allow the use in page_32.h without 
circular dependencies.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
