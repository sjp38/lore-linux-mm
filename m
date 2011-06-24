Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 14871900194
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 03:20:55 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LNA00J3G9QQ3K80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jun 2011 08:20:51 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNA00J0A9QPKX@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jun 2011 08:20:50 +0100 (BST)
Date: Fri, 24 Jun 2011 09:20:27 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 7/8] common: dma-mapping: change
 alloc/free_coherent method to more generic alloc/free_attrs
In-reply-to: <BANLkTinDN-FF5=8uj9pP58Ny0-LUMtjh=g@mail.gmail.com>
Message-id: <000001cc323f$3114d8c0$933e8a40$%szyprowski@samsung.com>
Content-language: pl
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
 <BANLkTikFdrOuXsLCfvyA_V+p7S_fd72dyQ@mail.gmail.com>
 <002401cc3005$a941c010$fbc54030$%szyprowski@samsung.com>
 <BANLkTinDN-FF5=8uj9pP58Ny0-LUMtjh=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'KyongHo Cho' <pullip.cho@samsung.com>
Cc: linux-arch@vger.kernel.org, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Wednesday, June 22, 2011 2:01 AM KyongHo Cho wrote:

> 2011/6/21 Marek Szyprowski <m.szyprowski@samsung.com>:
> >
> > You already got a reply that dropping dma_alloc_writecombine() is no
> > go on ARM.
> >
> Yes.
> 
> > That's not a problem. Once we agree on dma_alloc_attrs(), the drivers
> > can be changed to use DMA_ATTR_WRITE_COMBINE attribute. If the platform
> > doesn't support the attribute, it is just ignored. That's the whole
> > point of the attributes extension. Once a driver is converted to
> > dma_alloc_attrs(), it can be used without any changes either on platforms
> > that supports some specific attributes or the one that doesn't implement
> > support for any of them.
> >
> I just worried that removing an existing construct is not a simple job.
> You introduced 3 attributes: DMA_ATTR_WRITE_COMBINE, ***COHERENT and
> ***NO_KERNEL_VADDR

COHERENT is the default behavior when no attribute is provided. I also
don't want to remove existing calls to dma_alloc_coherent() and 
dma_alloc_writecombine() from the drivers. This can be done later, once
dma_alloc_attrs() API will stabilize.

> I replied earlier, I also indicated that write combining option for
> dma_alloc_*() is required.
> But it does not mean dma_map_ops must support that.
> I think dma_alloc_writecombine() can be implemented regardless of
> dma_map_ops.

The discussion about the need of dma_alloc_attrs() has been performed on
Memory Management Summit at Linaro Meeting in Budapest. It simplifies the
API and provides full backward compatibility for existing drivers.
 
> > Allocation is a separate operation from mapping to userspace. Mmap
> > operation should just map the buffer (represented by a cookie of type
> > dma_addr_t) to user address space.
> >
> > Note that some drivers (like framebuffer drivers for example) also
> > needs to have both types of mapping - one for user space and one for
> > kernel virtual space.
> 
> I meant that I think DMA_ATTR_NOKERNELVADDR is not required because
> you also introduced mmap callback.

I've already said that mmap callback is not related to the fact that the
buffer has been allocated with or without respective kernel virtual space
mapping. I really don't get what do you mean here.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
