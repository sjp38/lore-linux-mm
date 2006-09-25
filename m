Date: Mon, 25 Sep 2006 10:11:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: virtual mmap basics
In-Reply-To: <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0609250958370.23475@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
 <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Hmmm... Some more thoughts on virtual memory requirements

A page struct is 8 words on 32 bit platforms = 32 byte

On 64 bit we have 7 words... lets just go with 64.

The memory requirements for a memmap structure covering all of memory
(and also the virtual memory requirements for a virtual memmap)
 are 

32 bit 4K page size:

Regular:
4GB of adressable memory = 1 mio page structs = 32 MB.

PAE mode:
64GB of memory = 16  mio page structs = 512MB.

Hmm.... So without PAE mode we are fine on i386. The 512MB 
virtual space requirement to support all of 64GB of memory with highmem 
64G may be difficult to fulfill. This is 1/8th of the address space!
Sparses ability to avoid virtual memory use comes in handy if memory is 
actually larger than supported by the processor. But then these 
configurations are becoming rarer with the advent of 64 bit processors.

On 64 bit platforms we need 64 byte per potential page.

The maximum on IA64 is 16TB. With a page size of 16k this gets you one 1 
Gig of pages which take up 64 GB of address space. This is the 
implementation that IA64 used from the beginning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
