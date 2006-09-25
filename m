Date: Mon, 25 Sep 2006 09:27:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: virtual mmap basics
In-Reply-To: <4517CB69.9030600@shadowen.org>
Message-ID: <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
 <4517CB69.9030600@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006, Andy Whitcroft wrote:

> pfn_valid is most commonly required on virtual mem_map setups as its
> implementation (currently) violates the 'contiguious and present' out to
> MAX_ORDER constraint that the buddy expects.  So we have additional
> frequent checks on pfn_valid in the allocator to check for it when there
> are holes within zones (which is virtual memmaps in all but name).

Why would the page allocator require frequent calls to pfn_valid? One 
you have the free lists setup then there is no need for it AFAIK.

Still pfn_valid with virtual memmap is still comparable to sparses 
current implementation. If the cpu has an instruction to check the 
validity of an address then it will be superior.

> We also need to consider the size of the mem_map.  The reason we have a
> problem with smaller machines is that virtual space in zone NORMAL is
> limited.  The mem_map here has to be contigious and spase in KVA, this
> is exactly the resource we are short of.

The point of the virtual memmap is that it does not have to be contiguous 
and it is sparse. Sparsemem could use that format and then we would be 
able to optimize important VM function such as virt_to_page() and 
page_address().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
