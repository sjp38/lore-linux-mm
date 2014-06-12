Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0214F6B01F3
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:42:46 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so672522pad.21
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 23:42:46 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ye4si40626212pbc.19.2014.06.11.23.42.44
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 23:42:46 -0700 (PDT)
Date: Thu, 12 Jun 2014 15:42:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 05/10] DMA, CMA: support arbitrary bitmap granularity
Message-ID: <20140612064255.GA12663@bbox>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-6-git-send-email-iamjoonsoo.kim@lge.com>
 <20140612060610.GH12415@bbox>
 <20140612064355.GC19918@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612064355.GC19918@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, kvm@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Graf <agraf@suse.de>, kvm-ppc@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 12, 2014 at 03:43:55PM +0900, Joonsoo Kim wrote:
> On Thu, Jun 12, 2014 at 03:06:10PM +0900, Minchan Kim wrote:
> > On Thu, Jun 12, 2014 at 12:21:42PM +0900, Joonsoo Kim wrote:
> > > ppc kvm's cma region management requires arbitrary bitmap granularity,
> > > since they want to reserve very large memory and manage this region
> > > with bitmap that one bit for several pages to reduce management overheads.
> > > So support arbitrary bitmap granularity for following generalization.
> > > 
> > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > 
> > > diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> > > index bc4c171..9bc9340 100644
> > > --- a/drivers/base/dma-contiguous.c
> > > +++ b/drivers/base/dma-contiguous.c
> > > @@ -38,6 +38,7 @@ struct cma {
> > >  	unsigned long	base_pfn;
> > >  	unsigned long	count;
> > >  	unsigned long	*bitmap;
> > > +	int order_per_bit; /* Order of pages represented by one bit */
> > 
> > Hmm, I'm not sure it's good as *general* interface even though it covers
> > existing usecases.
> > 
> > It forces a cma area should be handled by same size unit. Right?
> > It's really important point for this patchset's motivation so I will stop
> > review and wait other opinions.
> 
> If you pass 0 to order_per_bit, you can manage cma area in every
> size(page unit) you want. If you pass certain number to order_per_bit,
> you can allocate and release cma area in multiple of such page order.
> 
> I think that this is more general implementation than previous versions.

Fair enough.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
