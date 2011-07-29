Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D501A6B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 06:14:28 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LP3007SZB42Z3@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 29 Jul 2011 11:14:26 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LP300D9UB41VB@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 29 Jul 2011 11:14:26 +0100 (BST)
Date: Fri, 29 Jul 2011 12:14:25 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [RFC] ARM: dma_map|unmap_sg plus iommu
In-reply-to: <20110729093555.GA13522@8bytes.org>
Message-id: <001901cc4dd8$4afb4e40$e0f1eac0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: 
 <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com>
 <000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com>
 <20110729093555.GA13522@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joerg Roedel' <joro@8bytes.org>
Cc: "'Ramirez Luna, Omar'" <omar.ramirez@ti.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Ohad Ben-Cohen' <ohad@wizery.com>

Hello,

On Friday, July 29, 2011 11:36 AM Joerg Roedel wrote:

> On Fri, Jul 29, 2011 at 09:50:32AM +0200, Marek Szyprowski wrote:
> > On Thursday, July 28, 2011 11:10 PM Ramirez Luna, Omar wrote:
> 
> > > 2. tidspbridge driver sometimes needs to map a physical address into a
> > > fixed virtual address (i.e. the start of a firmware section is expected to
> > > be at dsp va 0x20000000), there is no straight forward way to do this with
> > > the dma api given that it only expects to receive a cpu_addr, a sg or a
> > > page, by adding iov_address I could pass phys and iov addresses in a sg
> > > and overcome this limitation, but, these addresses belong to:
> >
> > We also encountered the problem of fixed firmware address. We addressed is
by
> > setting io address space start to this address and letting device driver to
> > rely on the fact that the first call to dma_alloc() will match this address.
> 
> This sounds rather hacky. How about partitioning the address space for
> the device and give the dma-api only a part of it. The other parts can
> be directly mapped using the iommu-api then.

Well, I'm not convinced that iommu-api should be used by the device drivers 
directly. If possible we should rather extend dma-mapping than use such hacks.

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
