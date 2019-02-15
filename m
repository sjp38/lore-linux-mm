Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C642C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:36:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B47A21927
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:36:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CknEENK4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B47A21927
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDEA68E0002; Thu, 14 Feb 2019 21:36:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8C0F8E0001; Thu, 14 Feb 2019 21:36:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A533C8E0002; Thu, 14 Feb 2019 21:36:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 626CD8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:36:52 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 59so5779888plc.13
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:36:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=ybJ6FRmizCH+Ysla/KYM0KU4CJcaZTaDUg0Dc25IXgc=;
        b=XBapa8cLuNRj/GXa/wIgDjW7/Sw1gdJztonE+zb3XV888i3w55fiHqSmZ1JAnFWj2T
         hPLmavfmYG0E9LMyQhBvmGCm01GfqB0v1euQe9AXyPaEuhKPqFHjjje/Sa0hfP+Y7KOf
         KD3qVSXcXJQBjNSaICnQKBFmO9Bwc9BkAKSZ5eTTPj1p9PviYBVwjBa7RvUqP+RffOx0
         NJoPi7OZgt8jIGNYGZEaUsjuZOM2E28ZgdEoX8mBzXp8N6x/iiCh/MjNJfrppfDHL1w9
         7lntOa1/1BrtYRZYe4w7g6OEVKKYd8Da7X/ralCCWVgv2Fjq//jlDV4vgpkEZ54Ej7AC
         WiUw==
X-Gm-Message-State: AHQUAuaNXNm8zYqLWM/77CEGIZiuYtQ9SbSOXPhv/KgL38GgykmkRDti
	v2C8ymSovmhFwcJriBXcJcPSLG/6JnhXuoTRbU2lUj1unuVimfE2dz2SJydyM8ZZtZxwpDpSVHM
	HCzCss7kbF4m7XpV28Y5+KVCJXWMd3yPnJrKIYD0dMthvzWHYBAGjSeBTukii/YGCxdjTKfeWvx
	doRgM9P0tAJwIEYc0Xl5ruaFpBGGXVukv4JJTg19xXB83liIjiyF6b+UDPBRjUHkiSEMHbAnzK+
	ZIFKQNFHYP/G84N87R/3dmGqxbav+/yj6yXbEk9hHGMkuSOTDLfcHVpATxC4rTpIpzLtmG/w/jk
	DqBSpP+Z7CS/iMaVUdE9RvioiLZNoHj64tcs12p4sYiAJ7uqP+8sNdHiI356FqFpfyo+Qwa68dO
	d
X-Received: by 2002:a63:c946:: with SMTP id y6mr3107808pgg.109.1550198211953;
        Thu, 14 Feb 2019 18:36:51 -0800 (PST)
X-Received: by 2002:a63:c946:: with SMTP id y6mr3107748pgg.109.1550198210929;
        Thu, 14 Feb 2019 18:36:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198210; cv=none;
        d=google.com; s=arc-20160816;
        b=FVyN1HBwefU2dyAGjlJIoIWq1MrA5zM90FDB183aKV+gGOUAdTsk44xGfzlVLqoqOj
         Fzy1Fv58cy/hxj0hoDiqAYlE2cku6uMhQbetsijYri52XnKAephcfUVq1pfGsWwsRwV+
         JKib2okaFfc4hr15Fr+vQKzIYXP8TzAM6KZYxpO0ZCr8u0JncpveCVGbW2ma9N8Gkko/
         +jolnB4aDH7shHJCagkTVf/Oa5G8Cky0htlKqSc1UxCVvpQgYMlgAaMod/WjiJTLnW50
         2TrQoOVH8rsxqA6bYHJMY5M9/HvwWPuopx75XWu8dLfaB9lyACnQ4mORtGf22o2If7L3
         BQkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ybJ6FRmizCH+Ysla/KYM0KU4CJcaZTaDUg0Dc25IXgc=;
        b=Zf4V+n4ptPG66K9casOAtsTVPtUHS5XUiwPpQoJkt3w46uVIv8TwkocJgWwwnvCIrU
         TvMLJVXJCSw075TWCDO3bJ5bJu81jMDYgF3PB4mPHj06C/XdzWI+Le/OGvuj08to17DM
         PQHPg2qX7gUi7dVd4z1mX9ASyBCioWKWy5Llper09ObklKaIoeVkU9WWX1j6WF/aU0L3
         PIqNKPyh0s9pYvkiHL3nyw3a36PHz91OGmrYy2C3wFlknaTzlmFLyJFP5ncmZas2K1SX
         pJfBl+6cxnOL/orrNTqIE1Ld1Ps6ifJ5CPc4Rlm5NaGXc6TWNKRf49Mjmz8D4PAC/Jw3
         FcmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CknEENK4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t124sor1878275pgb.63.2019.02.14.18.36.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:36:50 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CknEENK4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=ybJ6FRmizCH+Ysla/KYM0KU4CJcaZTaDUg0Dc25IXgc=;
        b=CknEENK4WWQ15y3wJPfIxhUzIaUUiVppnBDGCGYaHDjVrtgl0kyqkNGqsjGZvo+yVL
         d4sh6wqoe+z/JuZevryqfNRHbo9vH2xm13dggmJG78gI3QkLRRoQvPJvUO5NGBv2qsb6
         1mxG6i+IgqvE8AQdCpqd15C0+yqMcgVFcU8mCPdE0SdXGCSLfuyRINJeS8SyxIgOCMU6
         jpkV7ZqePbD0McFyHLHqfNjptby50fXpYVBmGptpQJYIXjF4d22rudV9nc0PELTXp4AR
         Ei5KrURLyx69ritVapzRYgIFX+mYJ/EejNawVddqxsBS+Wht7f5qAQSdVHAnhrs8Cgjb
         LNbg==
X-Google-Smtp-Source: AHgI3IYtCM+dhZI2FfJRnUme1duZ/3d7ZuNv03wmI45ynR22iAVUN9tbmQqTQ2AjvRjC5MO6GHyrEA==
X-Received: by 2002:a65:6149:: with SMTP id o9mr3081509pgv.315.1550198210461;
        Thu, 14 Feb 2019 18:36:50 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id i8sm8817908pfj.18.2019.02.14.18.36.48
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:36:49 -0800 (PST)
Date: Fri, 15 Feb 2019 08:11:05 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com,
	sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de,
	airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org,
	pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org,
	boris.ostrovsky@oracle.com, jgross@suse.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org
Subject: [PATCH v4 0/9] mm: Use vm_map_pages() and vm_map_pages_zero() API
Message-ID: <20190215024104.GA26331@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Previouly drivers have their own way of mapping range of
kernel pages/memory into user vma and this was done by
invoking vm_insert_page() within a loop.

As this pattern is common across different drivers, it can
be generalized by creating new functions and use it across
the drivers.

vm_map_pages() is the API which could be used to map
kernel memory/pages in drivers which has considered vm_pgoff.

vm_map_pages_zero() is the API which could be used to map
range of kernel memory/pages in drivers which has not considered
vm_pgoff. vm_pgoff is passed default as 0 for those drivers.

We _could_ then at a later "fix" these drivers which are using
vm_map_pages_zero() to behave according to the normal vm_pgoff
offsetting simply by removing the _zero suffix on the function
name and if that causes regressions, it gives us an easy way to revert.

Tested on Rockchip hardware and display is working fine, including talking
to Lima via prime.

v1 -> v2:
        Few Reviewed-by.

        Updated the change log in [8/9]

        In [7/9], vm_pgoff is treated in V4L2 API as a 'cookie'
        to select a buffer, not as a in-buffer offset by design
        and it always want to mmap a whole buffer from its beginning.
        Added additional changes after discussing with Marek and
        vm_map_pages() could be used instead of vm_map_pages_zero().

v2 -> v3:
        Corrected the documentation as per review comment.

        As suggested in v2, renaming the interfaces to -
        *vm_insert_range() -> vm_map_pages()* and
        *vm_insert_range_buggy() -> vm_map_pages_zero()*.
        As the interface is renamed, modified the code accordingly,
        updated the change logs and modified the subject lines to use the
        new interfaces. There is no other change apart from renaming and
        using the new interface.

        Patch[1/9] & [4/9], Tested on Rockchip hardware.

v3 -> v4:
	Fixed build warnings on patch [8/9] reported by kbuild test robot.

Souptick Joarder (9):
  mm: Introduce new vm_map_pages() and vm_map_pages_zero() API
  arm: mm: dma-mapping: Convert to use vm_map_pages()
  drivers/firewire/core-iso.c: Convert to use vm_map_pages_zero()
  drm/rockchip/rockchip_drm_gem.c: Convert to use vm_map_pages()
  drm/xen/xen_drm_front_gem.c: Convert to use vm_map_pages()
  iommu/dma-iommu.c: Convert to use vm_map_pages()
  videobuf2/videobuf2-dma-sg.c: Convert to use vm_map_pages()
  xen/gntdev.c: Convert to use vm_map_pages()
  xen/privcmd-buf.c: Convert to use vm_map_pages_zero()

 arch/arm/mm/dma-mapping.c                          | 22 ++----
 drivers/firewire/core-iso.c                        | 15 +---
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c        | 17 +----
 drivers/gpu/drm/xen/xen_drm_front_gem.c            | 18 ++---
 drivers/iommu/dma-iommu.c                          | 12 +---
 drivers/media/common/videobuf2/videobuf2-core.c    |  7 ++
 .../media/common/videobuf2/videobuf2-dma-contig.c  |  6 --
 drivers/media/common/videobuf2/videobuf2-dma-sg.c  | 22 ++----
 drivers/xen/gntdev.c                               | 11 ++-
 drivers/xen/privcmd-buf.c                          |  8 +--
 include/linux/mm.h                                 |  4 ++
 mm/memory.c                                        | 81 ++++++++++++++++++++++
 mm/nommu.c                                         | 14 ++++
 13 files changed, 134 insertions(+), 103 deletions(-)

-- 
1.9.1

