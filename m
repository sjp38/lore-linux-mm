Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 704D16B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 11:30:47 -0400 (EDT)
Received: by ywb26 with SMTP id 26so2693511ywb.14
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 08:30:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201106131707.49217.arnd@arndb.de>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
	<BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
	<201106131707.49217.arnd@arndb.de>
Date: Tue, 14 Jun 2011 00:30:44 +0900
Message-ID: <BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
Subject: Re: [RFC 0/2] ARM: DMA-mapping & IOMMU integration
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-mm-sig@lists.linaro.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

Hi.

On Tue, Jun 14, 2011 at 12:07 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> I'm sure that the graphics people will disagree with you on that.
> Having the frame buffer mapped in write-combine mode is rather
> important when you want to efficiently output videos from your
> CPU.
>
I agree with you.
But I am discussing about dma_alloc_writecombine() in ARM.
You can see that only ARM and AVR32 implement it and there are few
drivers which use it.
No function in dma_map_ops corresponds to dma_alloc_writecombine().
That's why Marek tried to add 'alloc_writecombine' to dma_map_ops.

> I can understand that there are arguments why mapping a DMA buffer into
> user space doesn't belong into dma_map_ops, but I don't see how the
> presence of an IOMMU is one of them.
>
> The entire purpose of dma_map_ops is to hide from the user whether
> you have an IOMMU or not, so that would be the main argument for
> putting it in there, not against doing so.
>
I also understand the reasons why dma_map_ops maps a buffer into user space.
Mapping in device and user space at the same time or in a simple
approach may look good.
But I think mapping to user must be and driver-specific.
Moreover, kernel already provides various ways to map physical memory
to user space.
And I think that remapping DMA address that is in device address space
to user space is not a good idea
because DMA address is not same to physical address semantically if
features of IOMMU are implemented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
