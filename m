Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A270C43612
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 05:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB51A218AE
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 05:51:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="m1NoC2Hq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB51A218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 280E28E000C; Wed,  2 Jan 2019 00:51:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22F198E0002; Wed,  2 Jan 2019 00:51:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 147D88E000C; Wed,  2 Jan 2019 00:51:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFC868E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 00:51:57 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so38106243qte.10
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 21:51:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/RT2abgqnBKCQ74QwzoyIyU7Rv/U52C3iy99nR44H5o=;
        b=E/0CT5bO36xfpwVbOPPU65sfkWF5taPkP0tAllNtuS3dl4wNNDgrVGZlGHERmkIyos
         raH7ym7S74kbI/mbLMOSGtGKU6vfTTh+w49jhlK8QDIX4YaEvSavY4ICKK2lVBlYgmgc
         RXcV7LzvowRqGjbQ8+sEYPNg8eq7gWvv4hHwXuzuNS44jFe+T+4TXSrMWzKGHcJ86hnh
         XtW1LPkwkwKlLkHqQ/S6maCf1IwCamoDr3wczSmPeS++tdvNdZXB/RQPRD62J5qz5vmE
         V38bZwkFzmaw0bkc9G9/++9VtK1YorSRqA2fJTrZWNL0gc8vPCMyFwEtoW0ZJsro81en
         z7nw==
X-Gm-Message-State: AJcUukfgpLFjBvDBMCz3axhKzfe+jXbmF4nOX9VejqQEPqrrhcTFPuRP
	J8A7F9eZ7/HnXTl4z1ZJRMWpV2rvk7g1YMc4xs7pOXzQAK0U4prdl8z70X1Mbk+hYtIGsDMd977
	aMeZAJC8eTmIyxw6cvt/gT7ruWruVQiQ0MV0Mh9Zja21pVgfAM1bkV8uxoR8i3vO4QzGIMowO9y
	rxfxn1BNFAlNQtDZCW3l24J8YmvruY1iuiZ2dhB4wo4Rw8ox6O+5BECenWMQ195OGJ8cd2BOROt
	yzlK/iLW6w4NHwqfQL6oPl0WY3ll9Tj1dzGXwUOnkb6pVQ+JNynkYvWYdvCu3QBX+MRfVQ6+7sJ
	8BAd3vu8NsQVlctup4+Vrfvx7TwRDz5d6xrsL0lAPV3SHjeQc0G5uUCsfEbsxtJKtcOzCzngUyR
	U
X-Received: by 2002:ac8:6784:: with SMTP id b4mr41998017qtp.103.1546408317633;
        Tue, 01 Jan 2019 21:51:57 -0800 (PST)
X-Received: by 2002:ac8:6784:: with SMTP id b4mr41997988qtp.103.1546408316838;
        Tue, 01 Jan 2019 21:51:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546408316; cv=none;
        d=google.com; s=arc-20160816;
        b=FLmgiH7N6T0PcjuGFIzoJRzRmcA/UDcWqatvjii6wXQmkYFNwvlj7FYX5XxObj4S4h
         t/LjAr/ZUAaJsYRXkLcU/g9erBrfIdB5wi5+o1Ydqg7wzVOQhnmFpKZVCFWOPfcJ7JQB
         zhfXdahmhzMD7Yk3pQyF/eUf+kBHvwSY5LuFxAu32n2AR4nj++34EtxpndDTIbWdLvAn
         8EBbtsQsroNnWdcPPq1RBy+/tYBe/aKVhyTRYdUPvd9YmKpzPeaaF+fhPiVa7trOB7Cg
         C23QGgZCueR1Na+eAOa3rOiVnSPO3CH+kUQx904uEL3SQCg3S9Z8raFS7ri7/rYJtC5y
         y+Jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/RT2abgqnBKCQ74QwzoyIyU7Rv/U52C3iy99nR44H5o=;
        b=YVBzIjGkXz629g68lZos8aMd1GHVifj90VeuF7Yk8cutyNJiuS7qrTzF/pko4bcD8J
         W7LQ55U4K7JMGKiRPsvLemtMaAb9l2ur+Dr7/A0S36iwREccyFta2803zHJZnmo52LNr
         q9wjn09XVoWfUBMbUKbUK79nmIQTXe3fIU49dLc9siGTeWAE4FdeNt8R6wK2LCHXPYt2
         m3w/wXv8GiEQvn8hxwh3l56bLsA4bvN0jrV60D7CGOOXLppl//ziyPzUb4Y0rriHSUqv
         2Jt+85X4/Opddk/kn2mdyrLRdWXzOE4ukXWnttbqj/C+7nXy9y/qE7uVZiXYOFunYaJB
         ylow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=m1NoC2Hq;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l11sor44208235qtk.1.2019.01.01.21.51.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 21:51:56 -0800 (PST)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=m1NoC2Hq;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/RT2abgqnBKCQ74QwzoyIyU7Rv/U52C3iy99nR44H5o=;
        b=m1NoC2HqsQfyDG3eQXWCxZiWnU2XjiZIpTQPa+5vsHI3mqNz1EftTooPlMZQlxFfZ8
         JZ2zSWtwWl2/Z84PqKsLn35wscF4HMwRIE5ZiM/gSS87W9A2VP3RnRkgCRuFUxzuEw39
         3U+ycyEya+PCJmp8aBL4QQPSPNy+QlQHisk2M=
X-Google-Smtp-Source: AFSGD/U/cTetaNn2yuxykYMMgcxPM+HG9ZU6Nw6VmD3O2sHrZWwUWUUgYwwduvJqxV6VLHsvs9V8vcPOQLpfP2Pcta8=
X-Received: by 2002:ac8:6b50:: with SMTP id x16mr42135783qts.368.1546408316297;
 Tue, 01 Jan 2019 21:51:56 -0800 (PST)
MIME-Version: 1.0
References: <20181210011504.122604-1-drinkcat@chromium.org>
In-Reply-To: <20181210011504.122604-1-drinkcat@chromium.org>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Wed, 2 Jan 2019 13:51:45 +0800
Message-ID:
 <CANMq1KAmFKpcxi49wJyfP4N01A80B2d-2RGY2Wrwg0BvaFxAxg@mail.gmail.com>
Subject: Re: [PATCH v6 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
To: Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, 
	Mel Gorman <mgorman@techsingularity.net>, 
	Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, 
	lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Tomasz Figa <tfiga@google.com>, Yingjoe Chen <yingjoe.chen@mediatek.com>, hch@infradead.org, 
	Matthew Wilcox <willy@infradead.org>, Hsin-Yi Wang <hsinyi@chromium.org>, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102055145.2RPqYLkGUC88ZHTm0cKlmcjuIkJnMv7U5XEMsurfimk@z>

Hi all,

On Mon, Dec 10, 2018 at 9:15 AM Nicolas Boichat <drinkcat@chromium.org> wrote:
>
> This is a follow-up to the discussion in [1], [2].
>
> IOMMUs using ARMv7 short-descriptor format require page tables
> (level 1 and 2) to be allocated within the first 4GB of RAM, even
> on 64-bit systems.
>
> For L1 tables that are bigger than a page, we can just use __get_free_pages
> with GFP_DMA32 (on arm64 systems only, arm would still use GFP_DMA).
>
> For L2 tables that only take 1KB, it would be a waste to allocate a full
> page, so we considered 3 approaches:
>  1. This series, adding support for GFP_DMA32 slab caches.
>  2. genalloc, which requires pre-allocating the maximum number of L2 page
>     tables (4096, so 4MB of memory).
>  3. page_frag, which is not very memory-efficient as it is unable to reuse
>     freed fragments until the whole page is freed. [3]
>
> This series is the most memory-efficient approach.

Does anyone have any further comment on this series? If not, which
maintainer is going to pick this up? I assume Andrew Morton?

Thanks,

> stable@ note:
>   We confirmed that this is a regression, and IOMMU errors happen on 4.19
>   and linux-next/master on MT8173 (elm, Acer Chromebook R13). The issue
>   most likely starts from commit ad67f5a6545f ("arm64: replace ZONE_DMA
>   with ZONE_DMA32"), i.e. 4.15, and presumably breaks a number of Mediatek
>   platforms (and maybe others?).
>
> [1] https://lists.linuxfoundation.org/pipermail/iommu/2018-November/030876.html
> [2] https://lists.linuxfoundation.org/pipermail/iommu/2018-December/031696.html
> [3] https://patchwork.codeaurora.org/patch/671639/
>
> Changes since v1:
>  - Add support for SLAB_CACHE_DMA32 in slab and slub (patches 1/2)
>  - iommu/io-pgtable-arm-v7s (patch 3):
>    - Changed approach to use SLAB_CACHE_DMA32 added by the previous
>      commit.
>    - Use DMA or DMA32 depending on the architecture (DMA for arm,
>      DMA32 for arm64).
>
> Changes since v2:
>  - Reworded and expanded commit messages
>  - Added cache_dma32 documentation in PATCH 2/3.
>
> v3 used the page_frag approach, see [3].
>
> Changes since v4:
>  - Dropped change that removed GFP_DMA32 from GFP_SLAB_BUG_MASK:
>    instead we can just call kmem_cache_*alloc without GFP_DMA32
>    parameter. This also means that we can drop PATCH v4 1/3, as we
>    do not make any changes in GFP flag verification.
>  - Dropped hunks that added cache_dma32 sysfs file, and moved
>    the hunks to PATCH v5 3/3, so that maintainer can decide whether
>    to pick the change independently.
>
> Changes since v5:
>  - Rename ARM_V7S_TABLE_SLAB_CACHE to ARM_V7S_TABLE_SLAB_FLAGS.
>  - Add stable@ to cc.
>
> Nicolas Boichat (3):
>   mm: Add support for kmem caches in DMA32 zone
>   iommu/io-pgtable-arm-v7s: Request DMA32 memory, and improve debugging
>   mm: Add /sys/kernel/slab/cache/cache_dma32
>
>  Documentation/ABI/testing/sysfs-kernel-slab |  9 +++++++++
>  drivers/iommu/io-pgtable-arm-v7s.c          | 19 +++++++++++++++----
>  include/linux/slab.h                        |  2 ++
>  mm/slab.c                                   |  2 ++
>  mm/slab.h                                   |  3 ++-
>  mm/slab_common.c                            |  2 +-
>  mm/slub.c                                   | 16 ++++++++++++++++
>  tools/vm/slabinfo.c                         |  7 ++++++-
>  8 files changed, 53 insertions(+), 7 deletions(-)
>
> --
> 2.20.0.rc2.403.gdbc3b29805-goog
>

