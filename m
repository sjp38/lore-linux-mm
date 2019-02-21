Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6799CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 02:36:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F26D22086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 02:36:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RRDQaL2Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F26D22086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63B818E0057; Wed, 20 Feb 2019 21:36:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3878E0002; Wed, 20 Feb 2019 21:36:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B2D48E0057; Wed, 20 Feb 2019 21:36:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id D19CE8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 21:36:51 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id 202so2660912ljj.10
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 18:36:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IhT33+ZuZhnclLJtzrgLTvsh568OJwgxzHtt6EZoeoE=;
        b=CMLDzBk5avdG6jEQuzj/LUh76kJiD7BdKwwdM1j8Mn2K6F//zpphpmxWrP2wE770lv
         2o0/iqkks+8ZK3WAN7C0xrKUJ5OXGlX4DYlhylOCiLmjAH5ToRZ0LzS77JjWC8U6fxQy
         Byot0dfub4KQDZt5i3K6HOK8wBEzN1m3UykYJGeQncWL19gV2qYpYs08dtsFhBuE3r74
         dPTTWxGTBLVaK47prkbdXbLy/gwqkF29HBVQzEo0W18X0xLnWA4YxfjwGDjNEFcb+hWZ
         7pVt8EdaQsq9GSY1cntW7TQQa4XD4et6mcT7F9NwpKnY7JUs7hxpX1Xxr2ZP866Ih6cm
         VKOw==
X-Gm-Message-State: AHQUAuZz347mOy25latineMFC6AbJzT0t3xXvtmOcj8cBy1Kkq2CThSc
	NvTdKv2IKZnAQ+iNMVjCyj0xtaGhYZT3pMNaK1gyjN7HRAy1qYO3jHrpGvIsxatbEgU4wg6ComM
	zZNybQrit9coyRXhyde7Z3r9mGHveK0WqLNs6MjP3hm0Ieuhd5BN/HZ0x8g0v0AWX1kp/KCglDD
	Rf5XVD8y1na5CzOyEFmqOAA3oBj+yxVS7p5XEl8hA+XSei2Lu9G1a7ePsendzrAmcDfvHC0nsxO
	Tn0vbt8n+WrQJRMeYAZOXpaMEiI053idk+cQhvWE0qzyZkmuCbgs6m8eJug+XRk18H1EOn3NfBi
	BsE97rbT397UR4SYzVT2FMhuMJRSnTDAyFdTKE0NFd8cbo1vHb1S7pLWXxZPsP3ItYsCbJZZ2Qb
	N
X-Received: by 2002:a19:cf4f:: with SMTP id f76mr21991644lfg.125.1550716610861;
        Wed, 20 Feb 2019 18:36:50 -0800 (PST)
X-Received: by 2002:a19:cf4f:: with SMTP id f76mr21991591lfg.125.1550716609394;
        Wed, 20 Feb 2019 18:36:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550716609; cv=none;
        d=google.com; s=arc-20160816;
        b=tMFI5gtP4hQVxpOpiYZFPsj/bvbJ4QVIp6shts9bu2i5SMNmB3I0ymsWmAYL7wES7q
         njiNurhrUIdqytYKpUb6zrJ6rIVZ0M3Ap38qLAEWM7FiPjgCDj75a8yd8951sK59s+6I
         o+V9tdDIUMQwrnLHDl3n6XUpj9RSUBrNle00vGR23t+VRDFjs6KflXSUa0THzZTX/E8h
         mJWYP/mIthqXpXJe5tBYTtcb7HpyIcScMzFD11jg+8UZzpSwPdRXJ5pZ14NJchuc97Jk
         dena0Ajw9oZu32qU57HtqBKhrC5FsEzWktLf0xn8h4E/zh/GeuVOOvEYih1oxnJ3Sawd
         wGyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IhT33+ZuZhnclLJtzrgLTvsh568OJwgxzHtt6EZoeoE=;
        b=yfN1VLT2pk2vMAcJ1WWXY/BoWWMKZehu7yz+czD5bwXFSVhf/Tm767pIHcpTLXkV2a
         ueRhqBuWbKCv0Zt27e1tfM0duQNkRJs+dD/eF9h7n4bgilKrGccWzTpR0+amcf1y9OcW
         hhfjzygOg205ct3ttXF6tKaI8GhJpmkNTyElU31tSd3bUJ95nIq8KIJPPl8mal6hPy8x
         yyTpr/TpnR7tG6qsgOAF2PemkoCj2gMALAkS06o/9MX4dHuA3qC/clewycyz/qcCbHXU
         TvdbC1HBtOXzO2K9uy74thX8/W6bN/v6HAlIgvFHVzpSZ696jmNhaOuXSLB3XXfuxXZY
         BRaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RRDQaL2Y;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q190sor7160283ljb.7.2019.02.20.18.36.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 18:36:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RRDQaL2Y;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IhT33+ZuZhnclLJtzrgLTvsh568OJwgxzHtt6EZoeoE=;
        b=RRDQaL2Yr6th/tcc24ot1sRaI12xLnsOT26YVojzv6FLlBcPV4BZH7qKQYvXQRy0Ml
         xgHyh6bj9Xh4TnWOM//4cBWzFemxAhb+kUIo9tDssoivn0Hz/a7DNF7QkegBx20FAGCg
         YrkJeugdrrurdNvVCq5U1ghRK5uazu7WJejHQMyH1vDR0zb8y17em07zw1XqXQITvj8d
         Uf+f//sKtQqL8efMFlzW9j7KhEfvhhELp4ufj6w5q4pFpnciIRQPovl0FYOKzk9JzEti
         ZDqfX/rsuBnEGNqhZ3nCqJTwA7Q1wucr7yMhsychbrwxfUa5c4tLfu9P7jCmXg/ZYdVn
         gtfQ==
X-Google-Smtp-Source: AHgI3IahDoLmYSzyXftmcGNCvk1lLmWsiwGhF2S+3m4XfLJICiUO5nC5rltmz2rH5SPgMvCWKXFIHyOjBjhd24YBdDM=
X-Received: by 2002:a2e:9b99:: with SMTP id z25mr13905243lji.106.1550716608824;
 Wed, 20 Feb 2019 18:36:48 -0800 (PST)
MIME-Version: 1.0
References: <20190215024104.GA26331@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190215024104.GA26331@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 21 Feb 2019 08:11:02 +0530
Message-ID: <CAFqt6zbchvoD-MdEF2T52eOPQ2x4gZ4G-72oZkW5f_RiT1nXpA@mail.gmail.com>
Subject: Re: [PATCH v4 0/9] mm: Use vm_map_pages() and vm_map_pages_zero() API
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, 
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

On Fri, Feb 15, 2019 at 8:06 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Previouly drivers have their own way of mapping range of
> kernel pages/memory into user vma and this was done by
> invoking vm_insert_page() within a loop.
>
> As this pattern is common across different drivers, it can
> be generalized by creating new functions and use it across
> the drivers.
>
> vm_map_pages() is the API which could be used to map
> kernel memory/pages in drivers which has considered vm_pgoff.
>
> vm_map_pages_zero() is the API which could be used to map
> range of kernel memory/pages in drivers which has not considered
> vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
>
> We _could_ then at a later "fix" these drivers which are using
> vm_map_pages_zero() to behave according to the normal vm_pgoff
> offsetting simply by removing the _zero suffix on the function
> name and if that causes regressions, it gives us an easy way to revert.
>
> Tested on Rockchip hardware and display is working fine, including talking
> to Lima via prime.
>
> v1 -> v2:
>         Few Reviewed-by.
>
>         Updated the change log in [8/9]
>
>         In [7/9], vm_pgoff is treated in V4L2 API as a 'cookie'
>         to select a buffer, not as a in-buffer offset by design
>         and it always want to mmap a whole buffer from its beginning.
>         Added additional changes after discussing with Marek and
>         vm_map_pages() could be used instead of vm_map_pages_zero().
>
> v2 -> v3:
>         Corrected the documentation as per review comment.
>
>         As suggested in v2, renaming the interfaces to -
>         *vm_insert_range() -> vm_map_pages()* and
>         *vm_insert_range_buggy() -> vm_map_pages_zero()*.
>         As the interface is renamed, modified the code accordingly,
>         updated the change logs and modified the subject lines to use the
>         new interfaces. There is no other change apart from renaming and
>         using the new interface.
>
>         Patch[1/9] & [4/9], Tested on Rockchip hardware.
>
> v3 -> v4:
>         Fixed build warnings on patch [8/9] reported by kbuild test robot.
>
> Souptick Joarder (9):
>   mm: Introduce new vm_map_pages() and vm_map_pages_zero() API
>   arm: mm: dma-mapping: Convert to use vm_map_pages()
>   drivers/firewire/core-iso.c: Convert to use vm_map_pages_zero()
>   drm/rockchip/rockchip_drm_gem.c: Convert to use vm_map_pages()
>   drm/xen/xen_drm_front_gem.c: Convert to use vm_map_pages()
>   iommu/dma-iommu.c: Convert to use vm_map_pages()
>   videobuf2/videobuf2-dma-sg.c: Convert to use vm_map_pages()
>   xen/gntdev.c: Convert to use vm_map_pages()
>   xen/privcmd-buf.c: Convert to use vm_map_pages_zero()

If no further comment, is it fine to take these patches to -mm
tree for regression ?

>
>  arch/arm/mm/dma-mapping.c                          | 22 ++----
>  drivers/firewire/core-iso.c                        | 15 +---
>  drivers/gpu/drm/rockchip/rockchip_drm_gem.c        | 17 +----
>  drivers/gpu/drm/xen/xen_drm_front_gem.c            | 18 ++---
>  drivers/iommu/dma-iommu.c                          | 12 +---
>  drivers/media/common/videobuf2/videobuf2-core.c    |  7 ++
>  .../media/common/videobuf2/videobuf2-dma-contig.c  |  6 --
>  drivers/media/common/videobuf2/videobuf2-dma-sg.c  | 22 ++----
>  drivers/xen/gntdev.c                               | 11 ++-
>  drivers/xen/privcmd-buf.c                          |  8 +--
>  include/linux/mm.h                                 |  4 ++
>  mm/memory.c                                        | 81 ++++++++++++++++++++++
>  mm/nommu.c                                         | 14 ++++
>  13 files changed, 134 insertions(+), 103 deletions(-)
>
> --
> 1.9.1
>

