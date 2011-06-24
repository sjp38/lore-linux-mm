Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9DCC2900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 05:18:09 -0400 (EDT)
Date: Fri, 24 Jun 2011 11:18:07 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH/RFC 0/8] ARM: DMA-mapping framework redesign
Message-ID: <20110624091807.GC29299@8bytes.org>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>

Hi Marek,

On Mon, Jun 20, 2011 at 09:50:05AM +0200, Marek Szyprowski wrote:
> This patch series is a continuation of my works on implementing generic
> IOMMU support in DMA mapping framework for ARM architecture. Now I
> focused on the DMA mapping framework itself. It turned out that adding
> support for common dma_map_ops structure was not that hard as I initally
> thought. After some modification most of the code fits really well to
> the generic dma_map_ops methods.

I appreciate your progress on this generic dma_ops implementation. But
for now it looks very ARM specific. Do you have plans to extend it to
non-ARM iommu-api implementations too?

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
