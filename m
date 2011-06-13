Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0007E6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 11:08:07 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 0/2] ARM: DMA-mapping & IOMMU integration
Date: Mon, 13 Jun 2011 17:07:49 +0200
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com> <BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
In-Reply-To: <BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106131707.49217.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org
Cc: KyongHo Cho <pullip.cho@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

On Monday 13 June 2011 16:12:05 KyongHo Cho wrote:
> Of course, the mapping created by by dma_alloc_writecombine()
> may be more efficient for CPU to update the DMA buffer.
> But I think mapping with dma_alloc_coherent() is not such a
> performance bottleneck.
> 
> I think it is better to remove dma_alloc_writecombine() and replace
> all of it with dma_alloc_coherent().

I'm sure that the graphics people will disagree with you on that.
Having the frame buffer mapped in write-combine mode is rather
important when you want to efficiently output videos from your
CPU.

> In addition, IMHO, mapping to user's address is not a duty of dma_map_ops.
> dma_mmap_*() is not suitable for a system that has IOMMU
> because a DMA address does not equal to its correspondent physical
> address semantically.
> 
> I think DMA APIs of ARM must be changed drastically to support IOMMU
> because IOMMU API does not manage virtual address space.

I can understand that there are arguments why mapping a DMA buffer into
user space doesn't belong into dma_map_ops, but I don't see how the
presence of an IOMMU is one of them.

The entire purpose of dma_map_ops is to hide from the user whether
you have an IOMMU or not, so that would be the main argument for
putting it in there, not against doing so.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
