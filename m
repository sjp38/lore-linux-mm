Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86EBFC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 05:26:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 397C420856
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 05:26:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GSMfenxK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 397C420856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C15196B0007; Mon,  1 Apr 2019 01:26:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC6376B0008; Mon,  1 Apr 2019 01:26:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADB226B000A; Mon,  1 Apr 2019 01:26:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47AEB6B0007
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 01:26:16 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id 28so2132331ljv.14
        for <linux-mm@kvack.org>; Sun, 31 Mar 2019 22:26:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bIVPtU/6p+7QNpj3MFhNlKtXKn4Iq452QD8npHz+GbM=;
        b=TmHJHMYmUtCaCyS2XIjRypdnLJkMsdnVAergdUbm5qzKzg5Mx66+bQg93sSF2B+YKb
         lQGmcyzTSkYlDLd67NaUaZ5CAcAsasY0RMriMkPEYV93Ud9CEq0E2oHWFCCKrvNn8JSf
         dLeSvgo7w0Ka+xGMDoHbfZIKmwVJsiK/RrTuSZscpxIbZ8i8yN6uWYVpnodIyKR0gVc/
         7HXC+bbrJTpirp6nQ4s6Ltv3kyxp1S4Gz6BbPRgHr9BiIXs8CsLTirAcyc8DczfMH1pG
         2n9EvCfQ/8cJewPBHqXdbRVkcai4411xM7AWuqhVtHgjDJm5YZKkHsqXTaj5ob96LysM
         aXfQ==
X-Gm-Message-State: APjAAAUP6kFg8EkDsdpvsZk83YgdwDqsZUKq5nj8CZTEFkCpGBhHHBG0
	WQwgkj4MH/Xlo08jsQgGe2ftTMlaYwGQdXndP9tKJh65Crfi7oiaZqhBV/3fMD95z6jLniq7Gu9
	JJs1jRsnqRuqvdpLoOl6ka8JRo5QNWE4y+ItBLXBSbvcBNuOj/Av/6h0e42CNFZMmOQ==
X-Received: by 2002:a2e:99c5:: with SMTP id l5mr10604673ljj.55.1554096375512;
        Sun, 31 Mar 2019 22:26:15 -0700 (PDT)
X-Received: by 2002:a2e:99c5:: with SMTP id l5mr10604625ljj.55.1554096374322;
        Sun, 31 Mar 2019 22:26:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554096374; cv=none;
        d=google.com; s=arc-20160816;
        b=p4HEoBCfhur8+PHZ1+50yqnm15ryNZvOI1y6WijtSyFEOR7yJW2PwgNURge8/MnFhQ
         meHAcYQKUpw4gnVc8DFMVfazWyfzHafTVZqxdLaGjP7QnoUwoyxvrVu8o0PxYbwAM7cY
         rRTRTTpGS/uc4GDlMzpQBYaVIERoUM6Tr98lWDJ9awW3fejRyi+aGi+yn7mtRM2d+JnB
         1cuEDouG2NScTU9qLGA2lok1Yug/LPt+rghNseFzXHok0GybKEKYopx3yPTJCjlokauF
         bqscfZHKMkMtFilCbqaBktiN1iTUn6V+RJjHpPJCJ7DwTmGQ0izW2rmAc45KiV0mBxir
         PaFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bIVPtU/6p+7QNpj3MFhNlKtXKn4Iq452QD8npHz+GbM=;
        b=0JRT4e6HnVFB2ho4/T5BPpU9INTncm7fBrmHfpo2sMCNOI5Patg4VJvkC5Ul4n7mUw
         LoTr9KZC4IpyfacpusQEqVQxwWlEhCJIFIiXzuJfDs1n7HQlfazARU9UrOWvKNCd/3jw
         bu5hc4/S3pN0hOkEN6scgT38oZ4FawZQ6YNDXv/M8QWP0NS6h6zgvNoErQyz4YFHIKjI
         4KN9b9aENzV06ftSzvL9DfZadPzcPdLpDdq2M8E9oYV6JVll3LyZpsMVkWWh4LlKVW86
         PuPMHJN05eQj4/G46iWn5CH4nZLwbdsMAo/sAiGf3GcJLEXwJd8Se47LW+HyFWr5YP0c
         c85g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GSMfenxK;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t17sor4635369lje.43.2019.03.31.22.26.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 31 Mar 2019 22:26:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GSMfenxK;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bIVPtU/6p+7QNpj3MFhNlKtXKn4Iq452QD8npHz+GbM=;
        b=GSMfenxKmemWULo792hWOfy/Tlep6WqOO9L/jJR2e5gnB7dWER5LBXqu5dxALEN2tm
         inGtCLH8AGdUkulnrqLgYPflDKpirpF5+cHZAQ3XbB15xMH3nX22akA/pJVbyaAKZX85
         xvv8tvFX+ASSgFa7HJDqm0nA/zF6CKx+YjZJOYw4CYVXVz6IXPrmsRrnCO/I4IuXa9Ls
         vqGoW3074MgmcMmyS+MuUEhIbWdCqV8WxAafH2eVkIAnmnHDsOkbNTf28jHZj7mSs13i
         Yh6dW2t3w6dwsYv6iQ5J9TiAx/ermCxDUS4HhW8hxE8MVqmYyKd6GYwrESF9RaJ25eb+
         l02w==
X-Google-Smtp-Source: APXvYqzAIbEvWsJKCr8Si4qji6vpGtPpgJ9t/2hq0YVPrFKEma2+t934Gmkq9NVJTNcsivtQulGbZiMEOTK9cecCE6g=
X-Received: by 2002:a2e:3e18:: with SMTP id l24mr23912301lja.68.1554096373899;
 Sun, 31 Mar 2019 22:26:13 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552921225.git.jrdr.linux@gmail.com>
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 1 Apr 2019 10:56:02 +0530
Message-ID: <CAFqt6zaV5zcc495BBk1Wi7p+zOF8y=P5KRfKkvwY=stagUFKWQ@mail.gmail.com>
Subject: Re: [RESEND PATCH v4 0/9] mm: Use vm_map_pages() and
 vm_map_pages_zero() API
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

Hi Andrew,

On Tue, Mar 19, 2019 at 7:47 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
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

Is it fine to take these patches into mm tree for regression ?

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

