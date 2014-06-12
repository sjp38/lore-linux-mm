Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 91207900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:38:04 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id un15so712768pbc.34
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 00:38:04 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id pv8si40735483pbb.3.2014.06.12.00.38.02
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 00:38:03 -0700 (PDT)
Date: Thu, 12 Jun 2014 16:41:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 05/10] DMA, CMA: support arbitrary bitmap granularity
Message-ID: <20140612074140.GA20199@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-6-git-send-email-iamjoonsoo.kim@lge.com>
 <20140612070811.GI12415@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612070811.GI12415@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, kvm@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Graf <agraf@suse.de>, kvm-ppc@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 12, 2014 at 04:08:11PM +0900, Minchan Kim wrote:
> On Thu, Jun 12, 2014 at 12:21:42PM +0900, Joonsoo Kim wrote:
> > ppc kvm's cma region management requires arbitrary bitmap granularity,
> > since they want to reserve very large memory and manage this region
> > with bitmap that one bit for several pages to reduce management overheads.
> > So support arbitrary bitmap granularity for following generalization.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> 

Thanks.

[snip...]
> >  /**
> >   * dma_alloc_from_contiguous() - allocate pages from contiguous area
> >   * @dev:   Pointer to device for which the allocation is performed.
> > @@ -345,7 +372,8 @@ static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
> >  static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
> >  				       unsigned int align)
> >  {
> > -	unsigned long mask, pfn, pageno, start = 0;
> > +	unsigned long mask, pfn, start = 0;
> > +	unsigned long bitmap_maxno, bitmapno, nr_bits;
> 
> Just Nit: bitmap_maxno, bitmap_no or something consistent.
> I know you love consistent when I read description in first patch
> in this patchset. ;-)

Yeah, I will fix it. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
