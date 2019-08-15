Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EE0CC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 21:05:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43E8D2063F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 21:05:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="G0oO16fe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43E8D2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7E5D6B0003; Thu, 15 Aug 2019 17:05:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2FD06B0006; Thu, 15 Aug 2019 17:05:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF7346B0007; Thu, 15 Aug 2019 17:05:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id AA9C46B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:05:42 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4B1BE83E5
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 21:05:42 +0000 (UTC)
X-FDA: 75825893724.24.air26_14947f3a23f50
X-HE-Tag: air26_14947f3a23f50
X-Filterd-Recvd-Size: 7292
Received: from mail-oi1-f194.google.com (mail-oi1-f194.google.com [209.85.167.194])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 21:05:41 +0000 (UTC)
Received: by mail-oi1-f194.google.com with SMTP id l12so3303074oil.1
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:05:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=I9e+9SyZx5VjvjikBKAovwQqTND+yZ6kEHPzcscfEXE=;
        b=G0oO16fejfjWYZTvMwMXu1Cj0dJB+vzMWdZX60FZuJxsaZtB9Hh2GRTIiEvu7n/HUc
         ODziU0shukzdJhRQxjSrmbdCsOuHOl6K84hNu0OOL/dEnub2FwxcYiy+zMlUBsB1vTyI
         qRcNMwYCHL80rxe1hcCYXYOzRhr3CIQNIJf5B+XtQAwNls5Rg/NefPlxKNDE26KQUg2v
         Vy6/6grsDxl49OibXehH9M8ZdoyCw3IayUs+TEVJyVvDMb7xK0bdngQiLCcmtynC4BHR
         KS8s52/uidaXSeePXWMwQaydJttfelgy7WxMAQYx74mx6U2TyesDJIYykpZlhEB875ve
         cFWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=I9e+9SyZx5VjvjikBKAovwQqTND+yZ6kEHPzcscfEXE=;
        b=RSra2xFBcWcRemfTmonPU3TgZH5GunHuvihzionvRzrjbFmD0Yfx8K98NflmFOzf+5
         aZ9VlcFUNTr/1CiK2NOuNEPgVL/JI3gsB5sO2/6Ze+F9/a5jUt9EhT2cwAldIeMOoOl8
         ULAVaBahONqzFFezvBRNMI7mK7M3El+ORfukgTPB5oykiCKyD0L8AjDZaX5tBAViVc6R
         Ba25C978QK17XVop0dOur5KZvlUZBaw1tMLdsYVreXX4QMGOqOBg7TOeuYWoclK6sfmY
         DpSmlgD/B9dR5Y3/A8pD0bHXGRVLcrAnmhq4yue4VvXUJF2i5r4TYOyeaRAFFL4uhMs5
         qVzA==
X-Gm-Message-State: APjAAAWknzXXgE/Srpp0V5+3kBaFPUrc+DHLgv/sCbkLqS4+S6CbLLeT
	es5aeFJIIgIotgZcnVLBnSmHQDBE8h4LGw18plXcdA==
X-Google-Smtp-Source: APXvYqxYSbulXo1jOKOyMJ30tBrdjOaomDGOnrp8V3xfCU7oj/pEvcII1W7WTWGA2OrnhNw6y+FgIV2qLf0CSUXVVGg=
X-Received: by 2002:a05:6808:914:: with SMTP id w20mr2648263oih.73.1565903140485;
 Thu, 15 Aug 2019 14:05:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190809074520.27115-1-aneesh.kumar@linux.ibm.com> <20190809074520.27115-4-aneesh.kumar@linux.ibm.com>
In-Reply-To: <20190809074520.27115-4-aneesh.kumar@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 15 Aug 2019 14:05:29 -0700
Message-ID: <CAPcyv4hc_-oGMp6jGVknnYs+rmj4W1A_gFCbmAX2LFw0hsfL5g@mail.gmail.com>
Subject: Re: [PATCH v5 3/4] mm/nvdimm: Use correct #defines instead of open coding
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 9, 2019 at 12:45 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Use PAGE_SIZE instead of SZ_4K and sizeof(struct page) instead of 64.
> If we have a kernel built with different struct page size the previous
> patch should handle marking the namespace disabled.

Each of these changes carry independent non-overlapping regression
risk, so lets split them into separate patches. Others might

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  drivers/nvdimm/label.c          | 2 +-
>  drivers/nvdimm/namespace_devs.c | 6 +++---
>  drivers/nvdimm/pfn_devs.c       | 3 ++-
>  drivers/nvdimm/region_devs.c    | 8 ++++----
>  4 files changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/nvdimm/label.c b/drivers/nvdimm/label.c
> index 73e197babc2f..7ee037063be7 100644
> --- a/drivers/nvdimm/label.c
> +++ b/drivers/nvdimm/label.c
> @@ -355,7 +355,7 @@ static bool slot_valid(struct nvdimm_drvdata *ndd,
>
>         /* check that DPA allocations are page aligned */
>         if ((__le64_to_cpu(nd_label->dpa)
> -                               | __le64_to_cpu(nd_label->rawsize)) % SZ_4K)
> +                               | __le64_to_cpu(nd_label->rawsize)) % PAGE_SIZE)

The UEFI label specification has no concept of PAGE_SIZE, so this
check is a pure Linux-ism. There's no strict requirement why
slot_valid() needs to check for page alignment and it would seem to
actively hurt cross-page-size compatibility, so let's delete the check
and rely on checksum validation.

>                 return false;
>
>         /* check checksum */
> diff --git a/drivers/nvdimm/namespace_devs.c b/drivers/nvdimm/namespace_devs.c
> index a16e52251a30..a9c76df12cb9 100644
> --- a/drivers/nvdimm/namespace_devs.c
> +++ b/drivers/nvdimm/namespace_devs.c
> @@ -1006,10 +1006,10 @@ static ssize_t __size_store(struct device *dev, unsigned long long val)
>                 return -ENXIO;
>         }
>
> -       div_u64_rem(val, SZ_4K * nd_region->ndr_mappings, &remainder);
> +       div_u64_rem(val, PAGE_SIZE * nd_region->ndr_mappings, &remainder);
>         if (remainder) {
> -               dev_dbg(dev, "%llu is not %dK aligned\n", val,
> -                               (SZ_4K * nd_region->ndr_mappings) / SZ_1K);
> +               dev_dbg(dev, "%llu is not %ldK aligned\n", val,
> +                               (PAGE_SIZE * nd_region->ndr_mappings) / SZ_1K);
>                 return -EINVAL;

Yes, looks good, but this deserves its own independent patch.

>         }
>
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 37e96811c2fc..c1d9be609322 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -725,7 +725,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>                  * when populating the vmemmap. This *should* be equal to
>                  * PMD_SIZE for most architectures.
>                  */
> -               offset = ALIGN(start + SZ_8K + 64 * npfns, align) - start;
> +               offset = ALIGN(start + SZ_8K + sizeof(struct page) * npfns,

I'd prefer if this was not dynamic and was instead set to the maximum
size of 'struct page' across all archs just to enhance cross-arch
compatibility. I think that answer is '64'.
> +                              align) - start;
>         } else if (nd_pfn->mode == PFN_MODE_RAM)
>                 offset = ALIGN(start + SZ_8K, align) - start;
>         else
> diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
> index af30cbe7a8ea..20e265a534f8 100644
> --- a/drivers/nvdimm/region_devs.c
> +++ b/drivers/nvdimm/region_devs.c
> @@ -992,10 +992,10 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
>                 struct nd_mapping_desc *mapping = &ndr_desc->mapping[i];
>                 struct nvdimm *nvdimm = mapping->nvdimm;
>
> -               if ((mapping->start | mapping->size) % SZ_4K) {
> -                       dev_err(&nvdimm_bus->dev, "%s: %s mapping%d is not 4K aligned\n",
> -                                       caller, dev_name(&nvdimm->dev), i);
> -
> +               if ((mapping->start | mapping->size) % PAGE_SIZE) {
> +                       dev_err(&nvdimm_bus->dev,
> +                               "%s: %s mapping%d is not %ld aligned\n",
> +                               caller, dev_name(&nvdimm->dev), i, PAGE_SIZE);
>                         return NULL;
>                 }
>
> --
> 2.21.0
>

