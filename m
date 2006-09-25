Date: Mon, 25 Sep 2006 14:05:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: virtual mmap basics
In-Reply-To: <Pine.LNX.4.64.0609250958370.23475@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0609251401260.24262@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
 <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0609250958370.23475@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006, Christoph Lameter wrote:

> PAE mode:
> 64GB of memory = 16  mio page structs = 512MB.
> 
> Hmm.... So without PAE mode we are fine on i386. The 512MB 
> virtual space requirement to support all of 64GB of memory with highmem 
> 64G may be difficult to fulfill. This is 1/8th of the address space!
> Sparses ability to avoid virtual memory use comes in handy if memory is 
> actually larger than supported by the processor. But then these 
> configurations are becoming rarer with the advent of 64 bit processors.

On the other hand the PAE sparse approach is not that good for 
i386 with 64GB. Sparse memmmap must be in regular memory and thus we
are forced to use 512 MB of the available 900MB in lowmem for
memmap.

Using a virtual memmap there would allow relocation of the memmap array 
into high memory and would double the available low memory. So may be 
worth even on this 32 bit platform to sacrifice 1/8th of the virtual 
address space for memmap.

So far I am not seeing any convincing case for the current sparsemem table 
lookups. But there must have been some reason that such an implementation 
was chosen. What was it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
