Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 168ED6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:15:42 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id ma3so3800599pbc.15
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:15:41 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id rq2si9641397pbc.163.2014.06.15.22.15.40
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:15:41 -0700 (PDT)
Date: Mon, 16 Jun 2014 14:19:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 04/10] DMA, CMA: support alignment constraint on cma
 region
Message-ID: <20140616051952.GB23210@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-5-git-send-email-iamjoonsoo.kim@lge.com>
 <xa1t8up2jvi9.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1t8up2jvi9.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jun 12, 2014 at 12:02:38PM +0200, Michal Nazarewicz wrote:
> On Thu, Jun 12 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > ppc kvm's cma area management needs alignment constraint on
> 
> I've noticed it earlier and cannot seem to get to terms with this.  It
> should IMO be PPC, KVM and CMA since those are acronyms.  But if you
> have strong feelings, it's not a big issue.

Yes, I will fix it.

> 
> > cma region. So support it to prepare generalization of cma area
> > management functionality.
> >
> > Additionally, add some comments which tell us why alignment
> > constraint is needed on cma region.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> > diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> > index 8a44c82..bc4c171 100644
> > --- a/drivers/base/dma-contiguous.c
> > +++ b/drivers/base/dma-contiguous.c
> > @@ -219,6 +220,7 @@ core_initcall(cma_init_reserved_areas);
> >   * @size: Size of the reserved area (in bytes),
> >   * @base: Base address of the reserved area optional, use 0 for any
> >   * @limit: End address of the reserved memory (optional, 0 for any).
> > + * @alignment: Alignment for the contiguous memory area, should be
> >  	power of 2
> 
> a??must be power of 2 or zeroa??.

Okay.

> >   * @res_cma: Pointer to store the created cma region.
> >   * @fixed: hint about where to place the reserved area
> >   *
> > @@ -233,15 +235,15 @@ core_initcall(cma_init_reserved_areas);
> >   */
> >  static int __init __dma_contiguous_reserve_area(phys_addr_t size,
> >  				phys_addr_t base, phys_addr_t limit,
> > +				phys_addr_t alignment,
> >  				struct cma **res_cma, bool fixed)
> >  {
> >  	struct cma *cma = &cma_areas[cma_area_count];
> > -	phys_addr_t alignment;
> >  	int ret = 0;
> >  
> > -	pr_debug("%s(size %lx, base %08lx, limit %08lx)\n", __func__,
> > -		 (unsigned long)size, (unsigned long)base,
> > -		 (unsigned long)limit);
> > +	pr_debug("%s(size %lx, base %08lx, limit %08lx align_order %08lx)\n",
> > +		__func__, (unsigned long)size, (unsigned long)base,
> > +		(unsigned long)limit, (unsigned long)alignment);
> 
> Nit: Align with the rest of the arguments, i.e.:
> 
> +	pr_debug("%s(size %lx, base %08lx, limit %08lx align_order %08lx)\n",
> +		 __func__, (unsigned long)size, (unsigned long)base,
> +		 (unsigned long)limit, (unsigned long)alignment);

What's the difference between mine and yours?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
