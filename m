Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 203AB6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 03:04:51 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LPN0004QFO10X@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 09 Aug 2011 08:04:49 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LPN00EY9FO06Q@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Aug 2011 08:04:48 +0100 (BST)
Date: Tue, 09 Aug 2011 09:04:26 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [RFC] ARM: dma_map|unmap_sg plus iommu
In-reply-to: 
 <CAB-zwWj-VCWQ6h8wjv7owG7n7p59Ep4qXiQY3LruT64sikuSKg@mail.gmail.com>
Message-id: <01eb01cc5662$93287e30$b9797a90$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: 
 <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com>
 <000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com>
 <20110729093555.GA13522@8bytes.org>
 <001901cc4dd8$4afb4e40$e0f1eac0$%szyprowski@samsung.com>
 <20110729105422.GB13522@8bytes.org>
 <004201cc4dfb$47ee4770$d7cad650$%szyprowski@samsung.com>
 <CAHQjnOM58AReFuDpcSjHvNP2UZX1ZUeuWyfWCG6Ayxdfj4QE7w@mail.gmail.com>
 <CAB-zwWj-VCWQ6h8wjv7owG7n7p59Ep4qXiQY3LruT64sikuSKg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Ramirez Luna, Omar'" <omar.ramirez@ti.com>, 'KyongHo Cho' <pullip.cho@samsung.com>
Cc: 'Joerg Roedel' <joro@8bytes.org>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Ohad Ben-Cohen' <ohad@wizery.com>, 'Marek Szyprowski' <m.szyprowski@samsung.com>

Hello,

On Monday, August 08, 2011 5:22 PM Ramirez Luna, Omar wrote:

> On Sun, Jul 31, 2011 at 7:57 PM, KyongHo Cho <pullip.cho@samsung.com> wrote:
> > On Fri, Jul 29, 2011 at 11:24 PM, Marek Szyprowski
> ...
> >> Right now I have no idea how to handle this better. Perhaps with should be
> >> possible
> >> to specify somehow the target dma_address when doing memory allocation, but
I'm
> >> not
> >> really convinced yet if this is really required.
> >>
> > What about using 'dma_handle' argument of alloc_coherent callback of
> > dma_map_ops?
> > Although it is an output argument, I think we can convey a hint or
> > start address to map
> > to the IO memory manager that resides behind dma API.
> 
> I also thought on this one, even dma_map_single receives a void *ptr
> which could be casted into a struct with both physical and virtual
> addresses to be mapped, but IMHO, this starts to add twists into the
> dma map parameters which might create confusion.

Nope, this is completely wrong approach. DMA-mapping is kernel wide, 
architecture independent API and you should not define any exceptions from it.

> > DMA API is so abstract that it cannot cover all requirements by
> > various device drivers;;
> 
> Agree.

>From my perspective DMA API is quite well designed as cross-architecture API.
The
only problem is the lack of documentation how to use it correctly in the
embedded
world.

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
