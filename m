Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD2A5C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 17:14:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91657214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 17:14:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1yXHm0Cw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91657214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11B016B0005; Tue, 20 Aug 2019 13:14:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A4A16B0006; Tue, 20 Aug 2019 13:14:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAD696B0007; Tue, 20 Aug 2019 13:14:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id C3FB36B0005
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:14:31 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 37FA3181AC9BA
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 17:14:31 +0000 (UTC)
X-FDA: 75843455142.20.ring20_275ffd1af5b10
X-HE-Tag: ring20_275ffd1af5b10
X-Filterd-Recvd-Size: 4890
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 17:14:30 +0000 (UTC)
Received: from mail-qt1-f171.google.com (mail-qt1-f171.google.com [209.85.160.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2BE22230F2
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 17:14:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566321269;
	bh=WGX3Gxv4dvM3DO7D4Aw57VijAg2RzIOgDn+ZtwXtLuA=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=1yXHm0Cw2txK8FKtm1lYL+ceKrY7DkUGFh280BlxT1m8fd1yJvGoIVx0XuwOhxQFl
	 3vnSgFW8lKZ5tU+8Sczz4E2yLgkfj7rC+uZiW9anhIz5JhqNZ2QuOhbB3Db0e6C+Ey
	 r3/UkDEl7xBODkwZSZVqMzmvS/NH9009SEaBt8yY=
Received: by mail-qt1-f171.google.com with SMTP id t12so6892193qtp.9
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:14:29 -0700 (PDT)
X-Gm-Message-State: APjAAAUNW2Xx0sLsyAZ4C57dLQjetZfN1r6GmRbyz6rLr38WqAb+VIUv
	uosl2ewm5QMuVGNSlzQxGjutyNNCriwqZLgMvw==
X-Google-Smtp-Source: APXvYqyY9ZsBecGQ3Xs5y7LG3j9BHwHgJiDVJDcbMsgosFCxqVWpdQe5Z5wA8XSvdYEItWSHAFvEDYIGvIF5NjfBNsQ=
X-Received: by 2002:ac8:44c4:: with SMTP id b4mr26942067qto.224.1566321268306;
 Tue, 20 Aug 2019 10:14:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190820145821.27214-1-nsaenzjulienne@suse.de> <20190820145821.27214-5-nsaenzjulienne@suse.de>
In-Reply-To: <20190820145821.27214-5-nsaenzjulienne@suse.de>
From: Rob Herring <robh+dt@kernel.org>
Date: Tue, 20 Aug 2019 12:14:16 -0500
X-Gmail-Original-Message-ID: <CAL_Jsq+Nr88Nvd_ZA8eJGm4xLwssv7CnDJLsnZyFqiM=EQWYxg@mail.gmail.com>
Message-ID: <CAL_Jsq+Nr88Nvd_ZA8eJGm4xLwssv7CnDJLsnZyFqiM=EQWYxg@mail.gmail.com>
Subject: Re: [PATCH v2 04/11] of/fdt: add early_init_dt_get_dma_zone_size()
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, 
	Stefan Wahren <wahrenst@gmx.net>, Marc Zyngier <marc.zyngier@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, 
	"moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, devicetree@vger.kernel.org, 
	"open list:GENERIC INCLUDE/ASM HEADER FILES" <linux-arch@vger.kernel.org>, Linux IOMMU <iommu@lists.linux-foundation.org>, 
	linux-mm@kvack.org, linux-riscv@lists.infradead.org, 
	Frank Rowand <frowand.list@gmail.com>, phill@raspberryi.org, 
	Florian Fainelli <f.fainelli@gmail.com>, Will Deacon <will@kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Anholt <eric@anholt.net>, 
	Matthias Brugger <mbrugger@suse.com>, 
	"moderated list:BROADCOM BCM2835 ARM ARCHITECTURE" <linux-rpi-kernel@lists.infradead.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 9:58 AM Nicolas Saenz Julienne
<nsaenzjulienne@suse.de> wrote:
>
> Some devices might have weird DMA addressing limitations that only apply
> to a subset of the available peripherals. For example the Raspberry Pi 4
> has two interconnects, one able to address the whole lower 4G memory
> area and another one limited to the lower 1G.
>
> Being an uncommon situation we simply hardcode the device wide DMA
> addressable memory size conditionally to the machine compatible name and
> set 'dma_zone_size' accordingly.
>
> Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
>
> ---
>
> Changes in v2:
> - New approach to getting dma_zone_size, instead of parsing the dts we
>   hardcode it conditionally to the machine compatible name.
>
>  drivers/of/fdt.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index 06ffbd39d9af..f756e8c05a77 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -27,6 +27,7 @@
>
>  #include <asm/setup.h>  /* for COMMAND_LINE_SIZE */
>  #include <asm/page.h>
> +#include <asm/dma.h>   /* for dma_zone_size */
>
>  #include "of_private.h"
>
> @@ -1195,6 +1196,12 @@ void __init early_init_dt_scan_nodes(void)
>         of_scan_flat_dt(early_init_dt_scan_memory, NULL);
>  }
>
> +void __init early_init_dt_get_dma_zone_size(void)

static

With that,

Reviewed-by: Rob Herring <robh@kernel.org>

> +{
> +       if (of_fdt_machine_is_compatible("brcm,bcm2711"))
> +               dma_zone_size = 0x3c000000;
> +}
> +
>  bool __init early_init_dt_scan(void *params)
>  {
>         bool status;
> @@ -1204,6 +1211,7 @@ bool __init early_init_dt_scan(void *params)
>                 return false;
>
>         early_init_dt_scan_nodes();
> +       early_init_dt_get_dma_zone_size();
>         return true;
>  }
>
> --
> 2.22.0
>

