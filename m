Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 74C156B0155
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:00:56 -0400 (EDT)
Received: by gxk23 with SMTP id 23so157700gxk.14
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 17:00:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <002401cc3005$a941c010$fbc54030$%szyprowski@samsung.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
	<BANLkTikFdrOuXsLCfvyA_V+p7S_fd72dyQ@mail.gmail.com>
	<002401cc3005$a941c010$fbc54030$%szyprowski@samsung.com>
Date: Wed, 22 Jun 2011 09:00:54 +0900
Message-ID: <BANLkTinDN-FF5=8uj9pP58Ny0-LUMtjh=g@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 7/8] common: dma-mapping: change
 alloc/free_coherent method to more generic alloc/free_attrs
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arch@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

2011/6/21 Marek Szyprowski <m.szyprowski@samsung.com>:
>
> You already got a reply that dropping dma_alloc_writecombine() is no
> go on ARM.
>
Yes.

> That's not a problem. Once we agree on dma_alloc_attrs(), the drivers
> can be changed to use DMA_ATTR_WRITE_COMBINE attribute. If the platform
> doesn't support the attribute, it is just ignored. That's the whole
> point of the attributes extension. Once a driver is converted to
> dma_alloc_attrs(), it can be used without any changes either on platforms
> that supports some specific attributes or the one that doesn't implement
> support for any of them.
>
I just worried that removing an existing construct is not a simple job.
You introduced 3 attributes: DMA_ATTR_WRITE_COMBINE, ***COHERENT and
***NO_KERNEL_VADDR

I replied earlier, I also indicated that write combining option for
dma_alloc_*() is required.
But it does not mean dma_map_ops must support that.
I think dma_alloc_writecombine() can be implemented regardless of dma_map_ops.

> Allocation is a separate operation from mapping to userspace. Mmap
> operation should just map the buffer (represented by a cookie of type
> dma_addr_t) to user address space.
>
> Note that some drivers (like framebuffer drivers for example) also
> needs to have both types of mapping - one for user space and one for
> kernel virtual space.

I meant that I think DMA_ATTR_NOKERNELVADDR is not required because
you also introduced mmap callback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
