Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB3FCC282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:28:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 846CB2175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:28:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sdsIfMHX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 846CB2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 183DA8E0047; Thu,  7 Feb 2019 11:28:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 133448E0002; Thu,  7 Feb 2019 11:28:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 049618E0047; Thu,  7 Feb 2019 11:28:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4998E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:28:20 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id e12-v6so97538ljb.18
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:28:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NqcbSbVgDZtdgzYO2knt/tKwP8VpBZkOZlHZOIDOo1c=;
        b=TTM5ezFwNMaPY1UfS6xbzfzlsyqVn4mgeKh2x4uuKKNgGXBM0xRDsATbUcJi2G3rIq
         drnLwsmqX3JNCCfAkFlelsJPwTB9cbqA4t77FuZGcoYaEUKiFxzEhGDUBXaVTMhMwJm7
         HlLbqqzIrMjlDxBCUSqay5UA1eZcAb4agl6KTSHDGjbbTMFBNu+jd+KWS1gfTTt8iDp8
         Hko2ec5G6Fu/C1khAWw0EiyvGxW6934MSbsoC4C1AioerassrmsENZhpNQCJYvv7cBcg
         XTIqxI57MYRHy9tuQlkRBlxftZrKHXykiIRFUn+LY5m5zmJeajfJmplUGqOPkH0OWOTk
         KVRw==
X-Gm-Message-State: AHQUAub591JZHGwGC3ZsM6GJfec4jK4ZJmuNwHpdBqm5FljxGEiWxEL+
	a8UbBna9moq+mXTqrDx4FELr2nV7PKVcOXXKLpW0fGt4ZOtY/H6VVUR0ofU5z0Agtf8KFnCD4cv
	3gkZAdef6sZHuK1sRbXI7fEFmeLJRa7j2LMb4ItwKzOIWhrzWfLi0jmhZyiHI/v9AJQIUv6chc8
	JK44nD3bhPkzYv5562r/Zn5wz9TMPY18MVQxTD5ajv9iH/pUu2dA3l1tPN4wCREm1tTmlCSZNu8
	BSaDWM37ZoALTKlGBD5VuSnM7nvo2JSNi7OJ4W9dTqGS3n3M10P6KtGBYGquBMFZ1t9gG0aWkBA
	cVOnY6tLbU4mPuhvgylU77OLPU2A3AgPoV+zv4Vwkx5UL/EWGO7ydJGktBcFW0YsLHr4LbjOX52
	w
X-Received: by 2002:a2e:81da:: with SMTP id s26-v6mr10544923ljg.183.1549556899927;
        Thu, 07 Feb 2019 08:28:19 -0800 (PST)
X-Received: by 2002:a2e:81da:: with SMTP id s26-v6mr10544763ljg.183.1549556896975;
        Thu, 07 Feb 2019 08:28:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549556896; cv=none;
        d=google.com; s=arc-20160816;
        b=dE82UvEciFAZ98cwqObWxR7Q3HBz1BIYhHfvPi7YAZkZj315y1D4AWvGhKe8fCHfkN
         iqQHL6JLzCxPv7oRgYRwCXQKGlb/9ZfrT0Zs6oIn56PR0fIVwRS/41h5cE87xwDgl5LT
         cFOBlmNA8bBHKHtZTuu3XMjzIkxFG5ldxVHfdeGCxxfKT6safytzqeI+2PdtXAOmnAkF
         ajbj7gV+9NlHE+wZvxj89m1PUX8tRz8iz9Qm3DTZzzhhkJAP3lrM5OC3dsOOmNFXUmsL
         U/7tDz21/B12JZfyfwpcoJCdOCc2zYb3y/ugn3un8PsRWLM/xdQrxmQG9AbFaAHYbs/M
         0MBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NqcbSbVgDZtdgzYO2knt/tKwP8VpBZkOZlHZOIDOo1c=;
        b=ldqWToNoHVZXQGNg8DJeKR/FUs6b49C5L7BPrkyOXV+WQ4cAQMSu/leUF/tzFaH1Uz
         3eIfc09K4CXh8jVIOnKwBy+YZ4kz6yaKaq1PSYNEqWayhM/Kqc9eSqnf9adi8ZwuPTde
         Dx8oY6A8W4l3qQUTak43c8XcJd9EYqKjwdaJkQtfWAj1EOs38O6yC0+JmPW6UMxAzCYp
         ZxLZi3wh7ImxKLeg+ki8yxOoTiwW5IaqEAwL0WAOin0rmSfzSBAc1nDeHVpX0JkukBgQ
         dfvbPvRyvqsr6q+6MGVdb0HOhXd3HXHUVp1YWjZRv4WydXJ/4edKef3+zyKqjV1cjuM9
         4g7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sdsIfMHX;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a27sor4992751lfl.7.2019.02.07.08.28.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 08:28:16 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sdsIfMHX;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NqcbSbVgDZtdgzYO2knt/tKwP8VpBZkOZlHZOIDOo1c=;
        b=sdsIfMHX6Hcka/qDE5Of4d5cYBnxOvraEFktqyRV/YqTIWmQsIImsZno3PQ3QXvChB
         Ih/lmi/xTQFFrMYlVw+S5XdPaTbtcdmJaI8T0TFfT7FjDEziF0CZBWusxURwBejpR0jo
         m17dh++ITWi1D5YnoDzkhxCwirtKtc6fisRf2hCqOBX+sgVz9neLdgyiHyHI4CQTE13q
         PuM67m2S0tSrsluLr/a5PN8VAlpJogm75t4FDAnhA8rZWD74jixsMvIjJLbLh3g6E3h8
         K6Eit5WubNjI0TfJ2ZFvGFVh5O2GekVAEB39bM78hq6gAe2q7LM58untWC3Km79KRHm5
         2PIw==
X-Google-Smtp-Source: AHgI3IacQaPz5X8pueH3UK+eZmUBIcx0wh/8ncR+XUULfqXQ5hVdvW3OYiNZZDwhd/JYuf3FmyVwgiVBSknCrkSOsQE=
X-Received: by 2002:a19:6514:: with SMTP id z20mr10885979lfb.31.1549556896462;
 Thu, 07 Feb 2019 08:28:16 -0800 (PST)
MIME-Version: 1.0
References: <1549455025-17706-1-git-send-email-rppt@linux.ibm.com> <1549455025-17706-2-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1549455025-17706-2-git-send-email-rppt@linux.ibm.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 7 Feb 2019 22:02:24 +0530
Message-ID: <CAFqt6zbvYKQS0NO3x9d45ubwf_MdEf67x1=xUHLb+ippCFmeQg@mail.gmail.com>
Subject: Re: [PATCH 1/2] memblock: remove memblock_{set,clear}_region_flags
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 6, 2019 at 6:01 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> The memblock API provides dedicated helpers to set or clear a flag on a
> memory region, e.g. memblock_{mark,clear}_hotplug().
>
> The memblock_{set,clear}_region_flags() functions are used only by the
> memblock internal function that adjusts the region flags.
> Drop these functions and use open-coded implementation instead.
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  include/linux/memblock.h | 12 ------------
>  mm/memblock.c            |  9 ++++++---
>  2 files changed, 6 insertions(+), 15 deletions(-)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 71c9e32..32a9a6b 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -317,18 +317,6 @@ void __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
>         for_each_mem_range_rev(i, &memblock.memory, &memblock.reserved, \
>                                nid, flags, p_start, p_end, p_nid)
>
> -static inline void memblock_set_region_flags(struct memblock_region *r,
> -                                            enum memblock_flags flags)
> -{
> -       r->flags |= flags;
> -}
> -
> -static inline void memblock_clear_region_flags(struct memblock_region *r,
> -                                              enum memblock_flags flags)
> -{
> -       r->flags &= ~flags;
> -}
> -
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  int memblock_set_node(phys_addr_t base, phys_addr_t size,
>                       struct memblock_type *type, int nid);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 0151a5b..af5fe8e 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -851,11 +851,14 @@ static int __init_memblock memblock_setclr_flag(phys_addr_t base,
>         if (ret)
>                 return ret;
>
> -       for (i = start_rgn; i < end_rgn; i++)
> +       for (i = start_rgn; i < end_rgn; i++) {
> +               struct memblock_region *r = &type->regions[i];

Is it fine if we drop this memblock_region *r altogether ?

> +
>                 if (set)
> -                       memblock_set_region_flags(&type->regions[i], flag);
> +                       r->flags |= flag;
>                 else
> -                       memblock_clear_region_flags(&type->regions[i], flag);
> +                       r->flags &= ~flag;
> +       }
>
>         memblock_merge_regions(type);
>         return 0;
> --
> 2.7.4
>

