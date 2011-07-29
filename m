Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 888A36B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 05:35:57 -0400 (EDT)
Date: Fri, 29 Jul 2011 11:35:55 +0200
From: 'Joerg Roedel' <joro@8bytes.org>
Subject: Re: [RFC] ARM: dma_map|unmap_sg plus iommu
Message-ID: <20110729093555.GA13522@8bytes.org>
References: <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com> <000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "'Ramirez Luna, Omar'" <omar.ramirez@ti.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Ohad Ben-Cohen' <ohad@wizery.com>

On Fri, Jul 29, 2011 at 09:50:32AM +0200, Marek Szyprowski wrote:
> On Thursday, July 28, 2011 11:10 PM Ramirez Luna, Omar wrote:

> > 2. tidspbridge driver sometimes needs to map a physical address into a
> > fixed virtual address (i.e. the start of a firmware section is expected to
> > be at dsp va 0x20000000), there is no straight forward way to do this with
> > the dma api given that it only expects to receive a cpu_addr, a sg or a
> > page, by adding iov_address I could pass phys and iov addresses in a sg
> > and overcome this limitation, but, these addresses belong to:
> 
> We also encountered the problem of fixed firmware address. We addressed is by
> setting io address space start to this address and letting device driver to
> rely on the fact that the first call to dma_alloc() will match this address.

This sounds rather hacky. How about partitioning the address space for
the device and give the dma-api only a part of it. The other parts can
be directly mapped using the iommu-api then.

Regards,

	Joerg
1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
