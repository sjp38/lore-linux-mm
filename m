Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SHC2Bg027021
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 13:12:02 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SHC2g5262252
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 11:12:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SHC2RM002499
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 11:12:02 -0600
Subject: Re: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0608280954100.27677@schroedinger.engr.sgi.com>
References: <20060828154413.E05721BD@localhost.localdomain>
	 <Pine.LNX.4.64.0608280954100.27677@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 28 Aug 2006 10:11:59 -0700
Message-Id: <1156785119.5913.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-08-28 at 10:01 -0700, Christoph Lameter wrote:
> On Mon, 28 Aug 2006, Dave Hansen wrote:
> > +/* align addr on a size boundary - adjust address up/down if needed */
> > +#define _ALIGN_UP(addr,size)    (((addr)+((size)-1))&(~((size)-1)))
> > +#define _ALIGN_DOWN(addr,size)  ((addr)&(~((size)-1)))
> > +
> > +/* align addr on a size boundary - adjust address up if needed */
> > +#define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
> 
> Note that there is a generic ALIGN macro in include/linux/kernel.h plus
> __ALIGNs in linux/linkage.h. Could you use that and get to some sane 
> conventin for all these ALIGN functions?

Sure.  I'll take a look.

> > +#
> > +# On PPC32 page size is 4K. For PPC64 we support either 4K or 64K software
> > +# page size. When using 64K pages however, whether we are really supporting
> > +# 64K pages in HW or not is irrelevant to those definitions.
> > +#
> 
> I guess this is an oversight. This has nothing to do with generic and does 
> not belong into mm/Kconfig

Yeah, this is gunk.  I'll put it back where it belongs.

> > +choice
> > +	prompt "Kernel Page Size"
> > +	depends on ARCH_GENERIC_PAGE_SIZE
> > +config PAGE_SIZE_4KB
> > +	bool "4KB"
> > +	help
> > +	  This lets you select the page size of the kernel.  For best 64-bit
> > +	  performance, a page size of larger than 4k is recommended.  For best
> > +	  32-bit compatibility on 64-bit architectures, a page size of 4KB
> > +	  should be selected (although most binaries work perfectly fine with
> > +	  a larger page size).
> > +
> > +	  4KB                For best 32-bit compatibility
> > +	  8KB and up         For best performance
> > +	  above 64k	     For kernel hackers only
> > +
> > +	  If you don't know what to do, choose 8KB (if available).
> > +	  Otherwise, choose 4KB.
> 
> The above also would need to be genericized.

That is genericized. ;)  Are there some bits that don't fit ia64 well?

> > +config PAGE_SIZE_8KB
> > +	bool "8KB"
> > +config PAGE_SIZE_16KB
> > +	bool "16KB"
> > +config PAGE_SIZE_64KB
> > +	bool "64KB"
> > +config PAGE_SIZE_512KB
> > +	bool "512KB"
> > +config PAGE_SIZE_4MB
> > +	bool "4MB"
> > +endchoice
> 
> But not all arches support this. Choices need to be restricted to what the 
> arch supports. What about support for other pagesizes in the future. IA64 
> could f.e.  support 128k and 256K pages sizes.

Take a look a few patches further down in the series.  Let me know if
this isn't resolved.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
