Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 216B2C3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 17:16:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3D58214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 17:16:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="XIs9UEkS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3D58214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75A1C6B0005; Tue, 20 Aug 2019 13:16:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70A8A6B0006; Tue, 20 Aug 2019 13:16:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6225A6B0007; Tue, 20 Aug 2019 13:16:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id 414E16B0005
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:16:57 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D8C718248AB3
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 17:16:56 +0000 (UTC)
X-FDA: 75843461232.13.toes47_3c9afa581aa1b
X-HE-Tag: toes47_3c9afa581aa1b
X-Filterd-Recvd-Size: 4064
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 17:16:56 +0000 (UTC)
Received: from mail-qk1-f178.google.com (mail-qk1-f178.google.com [209.85.222.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 567902332B
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 17:16:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566321415;
	bh=36RoA+pZe09a0o8vSPVqwWADJLZpVfbMeIU9BV28nPs=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=XIs9UEkSMvPxBnsd53e7jkN5NEI5/C7h8Ir8aLbuMxhu90HRaE3Sc6lc/xzj2MrL1
	 xUG8N1AvPqsw4DNAuxtwFWd/cIXDpfFE4tkp1UYhSdi86yw4x7vtkpqKGbI3cr0Q2O
	 KYpy6aYY3wEO3cToKeoOX0ItD4JzAtZeq59NctvU=
Received: by mail-qk1-f178.google.com with SMTP id m2so5130649qki.12
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:16:55 -0700 (PDT)
X-Gm-Message-State: APjAAAWBJYZrq93E2bjOqsvi30yJJw3PxDai2INfWCrW9Jat7NItYI5R
	CpTYlTw1k96iL0dqPgxy9erHydNvV+l0iRSrSQ==
X-Google-Smtp-Source: APXvYqwuF+PJndb+CroZT1MS5j54H47bxzE6ji7aLqlNUTkFV6I2ExfzQp8zw3/DWgp/8UNkiC1AWu81liXi+Rz7vJg=
X-Received: by 2002:a37:6944:: with SMTP id e65mr24769246qkc.119.1566321414471;
 Tue, 20 Aug 2019 10:16:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190820145821.27214-1-nsaenzjulienne@suse.de> <20190820145821.27214-4-nsaenzjulienne@suse.de>
In-Reply-To: <20190820145821.27214-4-nsaenzjulienne@suse.de>
From: Rob Herring <robh+dt@kernel.org>
Date: Tue, 20 Aug 2019 12:16:43 -0500
X-Gmail-Original-Message-ID: <CAL_JsqJT3UNVKpAt+3g-tosy=uCZTosUxD4RfVYjMJ-gpGmPiA@mail.gmail.com>
Message-ID: <CAL_JsqJT3UNVKpAt+3g-tosy=uCZTosUxD4RfVYjMJ-gpGmPiA@mail.gmail.com>
Subject: Re: [PATCH v2 03/11] of/fdt: add of_fdt_machine_is_compatible function
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
> Provides the same functionality as of_machine_is_compatible.
>
> Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
> ---
>
> Changes in v2: None
>
>  drivers/of/fdt.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index 9cdf14b9aaab..06ffbd39d9af 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -802,6 +802,13 @@ const char * __init of_flat_dt_get_machine_name(void)
>         return name;
>  }
>
> +static const int __init of_fdt_machine_is_compatible(char *name)

No point in const return (though name could possibly be const), and
the return could be bool instead.

With that,

Reviewed-by: Rob Herring <robh@kernel.org>

> +{
> +       unsigned long dt_root = of_get_flat_dt_root();
> +
> +       return of_flat_dt_is_compatible(dt_root, name);
> +}
> +
>  /**
>   * of_flat_dt_match_machine - Iterate match tables to find matching machine.
>   *
> --
> 2.22.0
>

