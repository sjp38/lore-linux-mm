Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F224CC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:02:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E0822184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:02:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="T8SEdQkm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E0822184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E913A6B0003; Thu,  8 Aug 2019 11:02:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E41BD6B0006; Thu,  8 Aug 2019 11:02:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D58366B0007; Thu,  8 Aug 2019 11:02:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2CA16B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:02:44 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 191so59245178pfy.20
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:02:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ExbLywp2n4riKzI1gMtYZu/WQrgrjE4vGU5JEUkphOM=;
        b=iG3v0ITCVdBNxhdGQA1vAsxbWLoa5qIOTsJbjp8DmN8Bg8z2xV4kJX03biPSW6wALI
         cd+Ckc23tdvM96ZhnYr1GIZCT+gkbZyJqBnkwshGt2Hm75ENIKqqxnr7MnlV7HqpO/+u
         VxN2HvBDk5iUdjDy5AwZb64Sq34FCODClcgDqsaLoMrZG3bxB8D8Q1HbGGGf1UfSNakD
         /DvRAJYYx+8gV4YEqrDiMWz2qFG0HHYsC6uGtpLApCarluX0hAjjP8crOc3p/+0Djna0
         Kje6APXYxtG30yKDWxiE4UuRk6KHLE4vzzrycabQ7xEftYrYjRQMs8TByup9xlsktH06
         /EGQ==
X-Gm-Message-State: APjAAAXqVmf5P1SzgDrdBjnGavl6STNT/X+wme7Ypx1XOg4GmwaPzeCw
	VZGvBNzWTnH2wTh9sMaM4jcDycnZIAekhydzWWgofsQuv6vl55Q2k9hoUVd3R4ioRCRnxsL09iS
	LXVJF/lSkIYUxbBzKecNnlkkqz4zXN+xFQe3oh6i3YY0OLrSlUF4Uf0/FcdjLGhaYbA==
X-Received: by 2002:a62:e716:: with SMTP id s22mr15917694pfh.250.1565276564224;
        Thu, 08 Aug 2019 08:02:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFPJ+rRjbJtb48d6zxdS5T024ZRsrEdoMM5/xGfScpkmI3H4ytpiWn5LwhUWR10pHuZ7bh
X-Received: by 2002:a62:e716:: with SMTP id s22mr15917621pfh.250.1565276563309;
        Thu, 08 Aug 2019 08:02:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565276563; cv=none;
        d=google.com; s=arc-20160816;
        b=UKVfmRjAAig+Bog/o7CDvokYNiHWNpgDoMonx0MBPq9FcQ4q/mx+3PIgR3WYWb3SLu
         xLy05GKUn5ETDs4nqsD8/jtDRM0PQdTJiE/EW+05RcJ/04f6uNikRVYNTik86q8r0kSz
         UVPx39lyi3bfgPabf8cKR88mkv8HkpyXdKV4HknwEdeX3fg9COSPMGdIzRGjXe/x0Gsm
         H08Q7W4tJ7fm2QdOna9HKhbsS/zzEw/3ttWK4oj3vLBOfHnrYtom5mvzLoKRJTeQgKvW
         cSQB660mHKVmOYtKga4yj2Y/zkT2I0pBDPeTbTYcmTCN1gNQbilVHLONBixz402azDHR
         +q3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ExbLywp2n4riKzI1gMtYZu/WQrgrjE4vGU5JEUkphOM=;
        b=EqKtS3dzGB8Un+CggKCyV5V7UeJd4QNTwQxtcETf7zjBgpDUee/usnN1iaHZOmR3X+
         qE4zlcd5k+08kKSmBX273xLVXsmRiFinOuvWG6ibbFUY6vRYdHOTlG+8P2HF0eISSnwV
         sdSl0XiV3UWNMCRnDMmz6jEpEmCh1ER6WlhBmqFkCtnSWwi4ZUrBUO0ZdCme5hBBx4iE
         RAB+8pnJchpFr0wjt4e2ppCkRtHWvqzo6F3s7zbC+LwQWNE3tU5xveV0eAxlxVFpwEAS
         6yLbisxF5nmhqFNlsDOwYOP92JVn3mtxQ81UjJfGwzECj6GBKaqGtLoQMEa+dVPmZT2r
         1llA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=T8SEdQkm;
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d1si47387409pla.75.2019.08.08.08.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 08:02:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=T8SEdQkm;
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-qt1-f170.google.com (mail-qt1-f170.google.com [209.85.160.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9DF5321882
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 15:02:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565276562;
	bh=dyMO+YEym8ib/r3ptFxeHa3pBfgJ53Bab+zG1JtBiD8=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=T8SEdQkmyDZjxpkvg3O5aa5y0IUhZYhli6BHqmZLmfiiG7lkr51b/UqgTFh1RGV+e
	 MfHwocgqqK6CPBSQL1LeWybLWFp8cKihuFna7gkTOy+M2wAZon7MndaSRynprNtU82
	 2zgEQWoOZhEBTgp3ROz8ugCpgJEPPuHt0voaKgmo=
Received: by mail-qt1-f170.google.com with SMTP id x22so19047854qtp.12
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:02:42 -0700 (PDT)
X-Received: by 2002:ac8:7593:: with SMTP id s19mr6019854qtq.136.1565276561735;
 Thu, 08 Aug 2019 08:02:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
 <20190731154752.16557-4-nsaenzjulienne@suse.de> <CAL_JsqKF5nh3hcdLTG5+6RU3_TnFrNX08vD6qZ8wawoA3WSRpA@mail.gmail.com>
 <2050374ac07e0330e505c4a1637256428adb10c4.camel@suse.de> <CAL_Jsq+LjsRmFg-xaLgpVx3miXN3hid3aD+mgTW__j0SbEFYjQ@mail.gmail.com>
 <12eb3aba207c552e5eb727535e7c4f08673c4c80.camel@suse.de>
In-Reply-To: <12eb3aba207c552e5eb727535e7c4f08673c4c80.camel@suse.de>
From: Rob Herring <robh+dt@kernel.org>
Date: Thu, 8 Aug 2019 09:02:30 -0600
X-Gmail-Original-Message-ID: <CAL_JsqJS6XBSc8DuK2sJApHtY4nCSFpLezf003YMD75THLHAqg@mail.gmail.com>
Message-ID: <CAL_JsqJS6XBSc8DuK2sJApHtY4nCSFpLezf003YMD75THLHAqg@mail.gmail.com>
Subject: Re: [PATCH 3/8] of/fdt: add function to get the SoC wide DMA
 addressable memory size
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, 
	Christoph Hellwig <hch@lst.de>, wahrenst@gmx.net, Marc Zyngier <marc.zyngier@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, 
	"moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, devicetree@vger.kernel.org, 
	Linux IOMMU <iommu@lists.linux-foundation.org>, linux-mm@kvack.org, 
	Frank Rowand <frowand.list@gmail.com>, phill@raspberryi.org, 
	Florian Fainelli <f.fainelli@gmail.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Anholt <eric@anholt.net>, 
	Matthias Brugger <mbrugger@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, 
	"moderated list:BROADCOM BCM2835 ARM ARCHITECTURE" <linux-rpi-kernel@lists.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 12:12 PM Nicolas Saenz Julienne
<nsaenzjulienne@suse.de> wrote:
>
> Hi Rob,
>
> On Mon, 2019-08-05 at 13:23 -0600, Rob Herring wrote:
> > On Mon, Aug 5, 2019 at 10:03 AM Nicolas Saenz Julienne
> > <nsaenzjulienne@suse.de> wrote:
> > > Hi Rob,
> > > Thanks for the review!
> > >
> > > On Fri, 2019-08-02 at 11:17 -0600, Rob Herring wrote:
> > > > On Wed, Jul 31, 2019 at 9:48 AM Nicolas Saenz Julienne
> > > > <nsaenzjulienne@suse.de> wrote:
> > > > > Some SoCs might have multiple interconnects each with their own DMA
> > > > > addressing limitations. This function parses the 'dma-ranges' on each of
> > > > > them and tries to guess the maximum SoC wide DMA addressable memory
> > > > > size.
> > > > >
> > > > > This is specially useful for arch code in order to properly setup CMA
> > > > > and memory zones.
> > > >
> > > > We already have a way to setup CMA in reserved-memory, so why is this
> > > > needed for that?
> > >
> > > Correct me if I'm wrong but I got the feeling you got the point of the patch
> > > later on.
> >
> > No, for CMA I don't. Can't we already pass a size and location for CMA
> > region under /reserved-memory. The only advantage here is perhaps the
> > CMA range could be anywhere in the DMA zone vs. a fixed location.
>
> Now I get it, sorry I wasn't aware of that interface.
>
> Still, I'm not convinced it matches RPi's use case as this would hard-code
> CMA's size. Most people won't care, but for the ones that do, it's nicer to
> change the value from the kernel command line than editing the dtb.

Sure, I fully agree and am not a fan of the CMA DT overlays I've seen.

> I get that
> if you need to, for example, reserve some memory for the video to work, it's
> silly not to hard-code it. Yet due to the board's nature and users base I say
> it's important to favor flexibility. It would also break compatibility with
> earlier versions of the board and diverge from the downstream kernel behaviour.
> Which is a bigger issue than it seems as most users don't always understand
> which kernel they are running and unknowingly copy configuration options from
> forums.
>
> As I also need to know the DMA addressing limitations to properly configure
> memory zones and dma-direct. Setting up the proper CMA constraints during the
> arch's init will be trivial anyway.

It was really just commentary on commit text as for CMA alone we have
a solution already. I agree on the need for zones.

>
> > > > IMO, I'd just do:
> > > >
> > > > if (of_fdt_machine_is_compatible(blob, "brcm,bcm2711"))
> > > >     dma_zone_size = XX;
> > > >
> > > > 2 lines of code is much easier to maintain than 10s of incomplete code
> > > > and is clearer who needs this. Maybe if we have dozens of SoCs with
> > > > this problem we should start parsing dma-ranges.
> > >
> > > FYI that's what arm32 is doing at the moment and was my first instinct. But
> > > it
> > > seems that arm64 has been able to survive so far without any machine
> > > specific
> > > code and I have the feeling Catalin and Will will not be happy about this
> > > solution. Am I wrong?
> >
> > No doubt. I'm fine if the 2 lines live in drivers/of/.
> >
> > Note that I'm trying to reduce the number of early_init_dt_scan_*
> > calls from arch code into the DT code so there's more commonality
> > across architectures in the early DT scans. So ideally, this can all
> > be handled under early_init_dt_scan() call.
>
> How does this look? (I'll split it in two patches and add a comment explaining
> why dt_dma_zone_size is needed)
>
> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index f2444c61a136..1395be40b722 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -30,6 +30,8 @@
>
>  #include "of_private.h"
>
> +u64 dt_dma_zone_size __ro_after_init;

Avoiding a call from arch code by just having a variable isn't really
better. I'd rather see a common, non DT specific variable that can be
adjusted. Something similar to initrd_start/end. Then the arch code
doesn't have to care what hardware description code adjusted the
value.

Rob

