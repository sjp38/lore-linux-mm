Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F20AC43444
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 11:40:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F257F20657
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 11:39:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DayZQjEB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F257F20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E1088E0003; Thu, 17 Jan 2019 06:39:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 865B18E0002; Thu, 17 Jan 2019 06:39:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72D5B8E0003; Thu, 17 Jan 2019 06:39:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 001348E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:39:58 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id l12-v6so2277476ljb.11
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:39:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RqoIkotrN3l6oMAC+JrcBK/f6kX7mxLOSugmUX8akyw=;
        b=OVF9xIaviAU53CF1vk71RBICUruTNJM1aMYMyJRgS+DjwkBPULSQJgIs0b3VmSnlFt
         LcSAVACTfoaNB/u56Ty7BX0AyTCPRJyF0lEyBWVKPTljwFyt+EMbYdxqQef+8WDqJ/Oj
         dxM55wBe9ayjydzvtyQ/8kI7pgotN7fDGMjQKKCvh10WxEYPvHxvGy8tqOgW4UYuKU46
         nbQBVBDG4jOmA2gNSnxApC+loeF60j51cSJHRtOFq81JboVIeSMit1HdRMN3leLpDj8p
         tFnSxHtd8Xu9DHGagO2W2BBFlU9rxOSxS66laOJ3BgAwrh80vO8Fl6h2M5V+AH/qroOs
         ltMA==
X-Gm-Message-State: AJcUukeAW2I2WKMyzJjeo5QqjVnCe01goFZkPIvK5kQNCtUTWrRUSau7
	/lpwogsQt9DmePdNimBrwebDVO5sQ9yofSU5ceVlk8czNL+qPWbWyqOadVqZTNKDABF9l2f85Zn
	18+mjrUp7mgPPvcd/6pEM2wQ+m38/DuuK3x3Lq3MD4IPuSgQwCTFmu5mHLoMSLY3M2klMQsaYj0
	LcHcZTcHRp33jWc/jLNvMOKRYHgTuPIkKS7oxHJJ1fo6kZCt8KTvm12GaiOQmGTIeolIecuQiur
	do9AYRx9u9/qDs76DNi+O1Zdz+RFdwSCHfXDdxuU0p2Wz5QOENEN1V0Oq7l1ce2HMmMn45AAoqp
	5+tS4S4uOlurhjxaMaPkunQtCYw0nInEB44ushsDnBclP56Wr7oJvi0uYYajJ9Ph/PACcMsP5x+
	N
X-Received: by 2002:a2e:6595:: with SMTP id e21-v6mr10117637ljf.123.1547725197931;
        Thu, 17 Jan 2019 03:39:57 -0800 (PST)
X-Received: by 2002:a2e:6595:: with SMTP id e21-v6mr10117592ljf.123.1547725196424;
        Thu, 17 Jan 2019 03:39:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547725196; cv=none;
        d=google.com; s=arc-20160816;
        b=CjN9+B159Tuet2aS2QHRRCHLue86o16SLa10dG8gbwx0+Evy2mfSvPqNF42Bc9Vz63
         Fh3zN1x1Vs1zx1NDvnVYSvudFoRvT6nmfvOmtqEVsbzI13vhJT0cSCTg8xkAxDxLHJY6
         YV07xxHHM4BXlqb+2a3j2YUFNttkW0G6PKQ49D+zSTdWz/SKRPOMMu8iT5vnmyKzIptM
         UOqIFEeowbeIthq0gE1aGaCVpawCuhFF3vHWcj/7L6FkLsIZSrzM+a8ur6/sn8xRG1sP
         z+n2/0INahG4idOwEp5qbt5VHwyvyTPD0vMmOIHC7oHd9XO8Xl9T7mNxjy7aOWIP/CHS
         4VYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RqoIkotrN3l6oMAC+JrcBK/f6kX7mxLOSugmUX8akyw=;
        b=vRHGxOlC+gz+kqXR0zrvJMhuUs0FdgnN0zPBGBakgHXMRzlAtuxqZQI1jo+bSK4OR7
         XjiMiw6CiNHKauke4Mpvi1Q4/s82adaKy0WYg+OFZHtPgscLszO4dj7C6O4e/IOzlNDe
         NWb8BOaOhWPycv6YM/2b3LVrwRVCx1r2rANyKDi67rOs7WeUPbI/tf7C3Up14p6qAQhH
         TCf29wuegO0SvUBcYK5e7pqUcU5IfOgbZkt/W1MuJvQjed88xX08TmTQBVMixJOy9EH2
         /EYhm429VwPZIrdSwGzdGBCdC97a/J4NzzvmPFN6RHkoEAyabhF4XSrvmoQX/qADHf9k
         bHSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DayZQjEB;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8-v6sor897086ljg.29.2019.01.17.03.39.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 03:39:56 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DayZQjEB;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RqoIkotrN3l6oMAC+JrcBK/f6kX7mxLOSugmUX8akyw=;
        b=DayZQjEBT5kOQpoGi2VFE+Lz9tTTebqwjWOtbR16+0ebGzGyTuopZskDO46rrePAbK
         BFC5JdciMoAWC9h7PJlZzQQ0ky6VS3J8892IWikOgujLnSbBE6TgeASgyluAhMvzn9D2
         AYZH+Gl/sQpeZAldKkNZ98b2mgEIDv9JueHq6yx86dBIzzP45DzORgxhjZF4+fiRweno
         imcNTDVw0ARgn2BvsyYZg+T/7ACPSpZZ8XovYCZ/Du+R1YTGAjk3caOSZqw9uj8li7fm
         FChxRc6CELYunH8+CjDkMxH72RK/c1lod6sd10VCbMjLbrqxbBpFigRZfKC1GoznVbl6
         K85w==
X-Google-Smtp-Source: ALg8bN4WjU3s0OSm/9YpUIQbO/Oo9A2A0MpGOiCgVD3iwev/FuzOnJlIV0vd6Lqn9vdpZcStOiDXH1xYeeYzkvOhrDc=
X-Received: by 2002:a2e:4601:: with SMTP id t1-v6mr9974371lja.111.1547725195689;
 Thu, 17 Jan 2019 03:39:55 -0800 (PST)
MIME-Version: 1.0
References: <20190111150541.GA2670@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111150541.GA2670@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 17 Jan 2019 17:09:43 +0530
Message-ID:
 <CAFqt6zYxCxzGjv3ea+dYQHcmt2P849ZgaVSH=b05m9P4=MTBEA@mail.gmail.com>
Subject: Re: [PATCH 0/9] Use vm_insert_range and vm_insert_range_buggy
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, 
	Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, 
	Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, 
	joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, 
	mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, 
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, 
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, 
	linux-media@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117113943.ZdQWXG1nlm1NbHVmjaQC0-HZyxnw5Qmae8tzpTJ8oU4@z>

On Fri, Jan 11, 2019 at 8:31 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Previouly drivers have their own way of mapping range of
> kernel pages/memory into user vma and this was done by
> invoking vm_insert_page() within a loop.
>
> As this pattern is common across different drivers, it can
> be generalized by creating new functions and use it across
> the drivers.
>
> vm_insert_range() is the API which could be used to mapped
> kernel memory/pages in drivers which has considered vm_pgoff
>
> vm_insert_range_buggy() is the API which could be used to map
> range of kernel memory/pages in drivers which has not considered
> vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
>
> We _could_ then at a later "fix" these drivers which are using
> vm_insert_range_buggy() to behave according to the normal vm_pgoff
> offsetting simply by removing the _buggy suffix on the function
> name and if that causes regressions, it gives us an easy way to revert.
>
> There is an existing bug in [7/9], where user passed length is not
> verified against object_count. For any value of length > object_count
> it will end up overrun page array which could lead to a potential bug.
> This is fixed as part of these conversion.
>
> Souptick Joarder (9):
>   mm: Introduce new vm_insert_range and vm_insert_range_buggy API
>   arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
>   drivers/firewire/core-iso.c: Convert to use vm_insert_range_buggy
>   drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
>   drm/xen/xen_drm_front_gem.c: Convert to use vm_insert_range
>   iommu/dma-iommu.c: Convert to use vm_insert_range
>   videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range_buggy
>   xen/gntdev.c: Convert to use vm_insert_range
>   xen/privcmd-buf.c: Convert to use vm_insert_range_buggy

Any further comment on these patches ?

>
>  arch/arm/mm/dma-mapping.c                         | 22 ++----
>  drivers/firewire/core-iso.c                       | 15 +----
>  drivers/gpu/drm/rockchip/rockchip_drm_gem.c       | 17 +----
>  drivers/gpu/drm/xen/xen_drm_front_gem.c           | 18 ++---
>  drivers/iommu/dma-iommu.c                         | 12 +---
>  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 22 ++----
>  drivers/xen/gntdev.c                              | 16 ++---
>  drivers/xen/privcmd-buf.c                         |  8 +--
>  include/linux/mm.h                                |  4 ++
>  mm/memory.c                                       | 81 +++++++++++++++++++++++
>  mm/nommu.c                                        | 14 ++++
>  11 files changed, 129 insertions(+), 100 deletions(-)
>
> --
> 1.9.1
>

