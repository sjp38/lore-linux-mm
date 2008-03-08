Received: by rv-out-0910.google.com with SMTP id f1so521409rvb.26
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 22:35:35 -0800 (PST)
Message-ID: <86802c440803072235r3ca6013cufae3ed62cd67e60f@mail.gmail.com>
Date: Fri, 7 Mar 2008 22:35:35 -0800
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] [8/13] Enable the mask allocator for x86
In-Reply-To: <Pine.LNX.4.64.0803071832500.12220@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200803071007.493903088@firstfloor.org>
	 <20080307090718.A609E1B419C@basil.firstfloor.org>
	 <Pine.LNX.4.64.0803071832500.12220@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 7, 2008 at 6:37 PM, Christoph Lameter <clameter@sgi.com> wrote:
> On Fri, 7 Mar 2008, Andi Kleen wrote:
>
>  > - Disable old ZONE_DMA
>  > No fixed size ZONE_DMA now anymore. All existing users of __GFP_DMA rely
>  > on the compat call to the maskable allocator in alloc/free_pages
>  > - Call maskable allocator initialization functions at boot
>  > - Add TRAD_DMA_MASK for the compat functions
>  > - Remove dma_reserve call
>
>  This looks okay for the disabling part. But note that there are various
>  uses of MAX_DMA_ADDRESS (sparsemem, bootmem allocator) that are currently
>  suboptimal because they set a boundary at 16MB for allocation of
>  potentially large operating system structures. That boundary continues to
>  exist despite the removal of ZONE_DMA?
>
>  It would be better to remove ZONE_DMA32 instead and enlarge ZONE_DMA so
>  that it can take over the role of ZONE_DMA. Set the boundary for
>  MAX_DMA_ADDRESS to the boundary for ZONE_DMA32. Then the
>  allocations for sparse and bootmem will be allocated above 4GB which
>  leaves lots of the lower space available for 32 bit DMA capable devices.

good. i like the idea...

How about system with only 4G or less?

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
