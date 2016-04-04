Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id A97D46B0284
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 11:06:18 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id bc4so164186896lbc.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 08:06:18 -0700 (PDT)
Received: from mail.free-electrons.com (down.free-electrons.com. [37.187.137.238])
        by mx.google.com with ESMTP id v71si13874383wmd.18.2016.04.04.08.06.16
        for <linux-mm@kvack.org>;
        Mon, 04 Apr 2016 08:06:17 -0700 (PDT)
Date: Mon, 4 Apr 2016 17:05:58 +0200
From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: Re: [PATCH 1/4] mm: add is_highmem_addr() helper
Message-ID: <20160404170558.0e3278b5@bbrezillon>
In-Reply-To: <57022253.70400@ti.com>
References: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
	<1459427384-21374-2-git-send-email-boris.brezillon@free-electrons.com>
	<57022253.70400@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vignesh R <vigneshr@ti.com>
Cc: David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dave Gordon <david.s.gordon@intel.com>, Mark Brown <broonie@kernel.org>, linux-spi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>, dmaengine@vger.kernel.org, Mauro Carvalho Chehab <m.chehab@samsung.com>, Hans Verkuil <hans.verkuil@cisco.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org, Richard Weinberger <richard@nod.at>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org, linux-mm@kvack.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On Mon, 4 Apr 2016 13:44:11 +0530
Vignesh R <vigneshr@ti.com> wrote:

> Hi,
> 
> On 03/31/2016 05:59 PM, Boris Brezillon wrote:
> > Add an helper to check if a virtual address is in the highmem region.
> > 
> > Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
> > ---
> >  include/linux/highmem.h | 13 +++++++++++++
> >  1 file changed, 13 insertions(+)
> > 
> > diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> > index bb3f329..13dff37 100644
> > --- a/include/linux/highmem.h
> > +++ b/include/linux/highmem.h
> > @@ -41,6 +41,14 @@ void kmap_flush_unused(void);
> >  
> >  struct page *kmap_to_page(void *addr);
> >  
> > +static inline bool is_highmem_addr(const void *x)
> > +{
> > +	unsigned long vaddr = (unsigned long)x;
> > +
> > +	return vaddr >=  PKMAP_BASE &&
> > +	       vaddr < ((PKMAP_BASE + LAST_PKMAP) * PAGE_SIZE);
> 
> 
> Shouldn't this be:
> 		vaddr < (PKMAP_BASE + (LAST_PKMAP * PAGE_SIZE)) ?

Oops, yes indeed.

Anyway, given Russell's feedback I don't think I'm gonna follow up on
this series.

Sorry.

Boris

-- 
Boris Brezillon, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
