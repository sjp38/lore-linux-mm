Message-ID: <3B449035.ED1A551F@earthlink.net>
Date: Thu, 05 Jul 2001 10:05:09 -0600
From: "Joseph A. Knapka" <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: on MAXMEM_PFN and VMALLOC_RESERVE
References: <200107051157.HAA10231@www21.ureach.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kapish@ureach.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Kapish K wrote:
> 
> Hello,
>  What does this code ( in arch/i386/kernel/setup.c ), actually
> imply?
> /*
>  *Determine low and high memory ranges:
>  */
> 
> max_low_pfn=max_pfn;
> if ( max_low_pfn > MAXMEM_PFN ){
>       max_low_pfn = MAXMEM_PFN;
> #ifndef CONFIG_HIGHMEM
>     /* Maximum memory usable is what is directlt addressable */
> Now here, what does this imply, and the significance of
> VMALLOC_RESERVE in the MAXMEM_PFN calculations ( as in setup.c )
> :MAXMEM_PFN PFN_DOWN(MAXMEM)
> where MAXMEM = (unsigned long) ( -PAGE_OFFSET - VMALLOC_RESERVE
> )
> Also, what is the significance of this in terms of physical RAM
> sizes of 128 mb or more ( even greater than 1 GB ). I assume
> that still will not be high mem.
> Any hints or pointers would be welcome.

Have a look at http://home.earthlink.net/~jknapka/linux-mm/kmap.html

Basically, MAX_MEM is the amount of address space available between
PAGE_OFFSET and the beginning of the VMALLOC_RESERVE area just
below 4GB. Thus, it's the maximum amount of physical RAM that
can be permanently mapped into kernel VM. max_low_pfn is the
highest page frame number of permanently-mapped RAM.

HTH,

-- Joe


-- Joe Knapka
"You know how many remote castles there are along the gorges? You
 can't MOVE for remote castles!" -- Lu Tze re. Uberwald
// Linux MM Documentation in progress:
// http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
* Evolution is an "unproven theory" in the same sense that gravity is. *
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
