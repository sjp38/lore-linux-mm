Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 527DA900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 04:39:11 -0400 (EDT)
Date: Fri, 24 Jun 2011 10:39:09 +0200
From: 'Joerg Roedel' <joro@8bytes.org>
Subject: Re: [Linaro-mm-sig] [PATCH 3/8] ARM: dma-mapping: use
	asm-generic/dma-mapping-common.h
Message-ID: <20110624083909.GB29299@8bytes.org>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <1308556213-24970-4-git-send-email-m.szyprowski@samsung.com> <BANLkTimHE2jzQAav465WaG3iWVeHPyNRNQ@mail.gmail.com> <002501cc3008$f000d600$d0028200$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002501cc3008$f000d600$d0028200$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'KyongHo Cho' <pullip.cho@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>

On Tue, Jun 21, 2011 at 01:47:03PM +0200, Marek Szyprowski wrote:
> > I also think that it is better to attach and to detach dma_map_ops
> > dynamically.
> 
> What's the point of such operations? Why do you want to change dma
> mapping methods in runtime?

That is dangerous. You have to make sure that there are no mappings
granted to the the device driver before changing the dma_ops of a device
at runtime. Otherwise existing mappings for a device may disappear and
confuse the driver and the device.

Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
