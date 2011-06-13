Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0D46B007E
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:00:18 -0400 (EDT)
Received: by gxk23 with SMTP id 23so3955145gxk.14
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 09:00:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110613154033.GA29185@1n450.cable.virginmedia.net>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
	<BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
	<201106131707.49217.arnd@arndb.de>
	<BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
	<20110613154033.GA29185@1n450.cable.virginmedia.net>
Date: Tue, 14 Jun 2011 01:00:16 +0900
Message-ID: <BANLkTikkCV=rWM_Pq6t6EyVRHcWeoMPUqw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] ARM: DMA-mapping & IOMMU integration
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

> FWIW, on ARMv6 and later hardware, the dma_alloc_coherent() provides
> writecombine memory (i.e. Normal Noncacheable), so no need for
> dma_alloc_writecombine(). On earlier architectures it is creating
> Strongly Ordered mappings (no writecombine).
>
Thanks.

Do you mean that dma_alloc_coherent() and dma_alloc_writecombine() are
not different
except some additional features of dma_alloc_coherent() in ARM?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
