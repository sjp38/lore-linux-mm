Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A34E49000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:33:05 -0400 (EDT)
Received: by yxn22 with SMTP id 22so659734yxn.14
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 07:33:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308556213-24970-4-git-send-email-m.szyprowski@samsung.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<1308556213-24970-4-git-send-email-m.szyprowski@samsung.com>
Date: Mon, 20 Jun 2011 23:33:00 +0900
Message-ID: <BANLkTimHE2jzQAav465WaG3iWVeHPyNRNQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 3/8] ARM: dma-mapping: use asm-generic/dma-mapping-common.h
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, Arnd Bergmann <arnd@arndb.de>

Hi.

Great job.

On Mon, Jun 20, 2011 at 4:50 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> +static inline void set_dma_ops(struct device *dev, struct dma_map_ops *o=
ps)
> +{
> + =A0 =A0 =A0 dev->archdata.dma_ops =3D ops;
> +}
> +

Who calls set_dma_ops()?
In the mach. initialization part?
What if a device driver does not want to use arch's dma_map_ops
when machine init procedure set a dma_map_ops?
Even though, may arch defiens their dma_map_ops in archdata of device struc=
ture,
I think it is not a good idea that is device structure contains a
pointer to dma_map_ops
that may not be common to all devices in a board.

I also think that it is better to attach and to detach dma_map_ops dynamica=
lly.
Moreover, a mapping is not permanent in our Exynos platform
because a System MMU may be turned off while runtime.

DMA API must come with IOMMU API to initialize IOMMU in runtime.

Regards,
Cho KyongHo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
