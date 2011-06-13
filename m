Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DE74D6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:00:06 -0400 (EDT)
Received: by yia13 with SMTP id 13so2664561yia.14
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 08:58:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201106131746.18972.arnd@arndb.de>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
	<201106131707.49217.arnd@arndb.de>
	<BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
	<201106131746.18972.arnd@arndb.de>
Date: Tue, 14 Jun 2011 00:58:22 +0900
Message-ID: <BANLkTinFNz5b-Duz_-pYyAShzFSUrORE_w@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] ARM: DMA-mapping & IOMMU integration
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>

> I'm totally not following this argument. This has nothing to do with IOMMU
> or not. If you have an IOMMU, the dma code will know where the pages are
> anyway, so it can always map them into user space. The dma code might
> have an easier way to do it other than follwoing the page tables.
>
Ah. Sorry for that. I mixed dma_alloc_* up with dma_map_*.
I identified the reason why mmap_* in dma_map_ops is required.
You mean that nothing but DMA API knows what pages will be mapped to user space.
Thanks anyway.

KyongHo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
