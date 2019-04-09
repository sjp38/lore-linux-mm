Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC657C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 06:17:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80E072083E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 06:17:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iKpuC37b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80E072083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D6FA6B0007; Tue,  9 Apr 2019 02:17:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 185996B0008; Tue,  9 Apr 2019 02:17:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09F8A6B000C; Tue,  9 Apr 2019 02:17:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 991E16B0007
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 02:17:52 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id j20so2180016lfh.23
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 23:17:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XVUI5sWl/mko1IjkbRDCczAOo+DWIKHvVwzZKO9ey8M=;
        b=RlBgkYva4QgNHirrTIlq9W7HI98nh+dTg5zFVbVB9PlgZJoj1DOcrLU2eyY0h4l3+M
         biRQ7IN/9bJmT3mf7kxlvIWvE6YsTgMCupSoo4JXUBvJ4bFrbBoCNOwdNLiWaiMRYclN
         sYc3HUpr6Ih+bD6Blt6Jrancb5MqjPxQy5IAaRWaEGQSDogHsXmQdKZ2cKGJINqKbBdP
         N4/K41k9iDGYO5tXq2PVh6AeufqZztpMYcxoMJtUaDyzV/ihHOYyl6BZPVcHlWstCAcb
         O5ZmBjX0rwmV8dlIBVZe+KgBCwBY/vaYSnWxL2tLQXRV4CRdNzTHUtTKIBFZeXpjgPzq
         7F2w==
X-Gm-Message-State: APjAAAXsNcyh5ivVXoZfDnqIXwFX0K1lErRIFUgmzCzptEhaPsEkqOjd
	BOQoW5IBDrOXlKqoE+Edfx5H1d5Kj463UmoZDt6YVXr8I66WoT2JbCd+rLhSMMGbmkSAqPqrUzG
	SdUJ3CwRL+gmPU+7gCfiNnUyc4NT0DrSc7dJm1eoOR4K+Xih7RdO+rw7bgFhnk/ADdA==
X-Received: by 2002:ac2:4246:: with SMTP id m6mr18676727lfl.131.1554790670609;
        Mon, 08 Apr 2019 23:17:50 -0700 (PDT)
X-Received: by 2002:ac2:4246:: with SMTP id m6mr18676671lfl.131.1554790669596;
        Mon, 08 Apr 2019 23:17:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554790669; cv=none;
        d=google.com; s=arc-20160816;
        b=eV2NlZyvpyUk5dbepQK4WUyz62X8bevClgAr0+2eKlEj/vypeGLm3FNim0Nr4YiS0W
         T9jPr9vkeRJe0l7cVF/ZZNOzYBeMQ+rxoLsv2mjE9JDDNKyfc3bcOlEaMVjXVKEDWLPG
         C9qKyFlimnzArpIh9mBQNfnA8xcuyi95garYfEsv05JSmcfbkOKsuAVj1fGa1I+egKzx
         XdD6c6C+g5HBDj8PBY97pYxmNvtM/WR8jEVNCLS5erXpfPjFZQ5aDeA/sCBArQhCkkVe
         6sIuLjfeAivT9xwE5iDsK5s+YHvNC73jrhbt3sXHscfxJ6fakD+enpDX/rhG9GZIZtmV
         P2ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XVUI5sWl/mko1IjkbRDCczAOo+DWIKHvVwzZKO9ey8M=;
        b=c46ZSt5j83TeLE3FT2L7Y/yyoNua+Ks9rq82WBwpn7aEX0CFp4tjry9MWcg1hcR9ZU
         Xtb4M+oGbulpighXIb7XG0xFM1sDMUs/WB1DsVGN93bT+q1P4WkaWgnTc+0/Ypcsr+2z
         H073R98nydF6Nk+2tJECJj8xTxrmKb08xSOJOeL69zuUqizwmgJ2lbfXkG8YlyA29O5r
         4kGuORMP2NnNDeSDMpgibE9LrKQHNeN1OocSTiLW30XR9y08nwY//N4mppvEYs/ujxPc
         FdJFzeEJwHXdwnUskX8BiqCTUWJRqLzT92y9sNc7yAaviNojOECiQcFyz+atOVi5dUAz
         qBZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iKpuC37b;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor1198575lfm.57.2019.04.08.23.17.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 23:17:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iKpuC37b;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XVUI5sWl/mko1IjkbRDCczAOo+DWIKHvVwzZKO9ey8M=;
        b=iKpuC37b/W9gnQHlKyXQsrbKJd+/drf2Hv8V3oXIdmLPXDVZ9PIoNs12K3H/oeXZSd
         ntqA/DPibQG3kCHwVQ1+u5E6p3D1xq3D5anzZWBFdTux4ntxY/u+UD79r72OeMCnFR4v
         +v8oEW8Pce6NPS6evVaWwTmOR8s28EpacqA8lf/PLOsdQOlml8q7m5VaVbiRssH/Cj+I
         lIdgJUEIvd3wzqVYEklHNeJxatPwj86ktRvsFhosFc+61nBn7yd3rTm8VkMoXQXoLx6I
         AfzL866vMcmHkMBVnb2EODlFqUt/Tf6sb5rLwjofq6ZQKlmgWDWmVXOru/yi09PGWw6w
         Hk4Q==
X-Google-Smtp-Source: APXvYqzRVyYQF95nCiqgET1kk0SjOcmMhC+aOUtHZXTsDUtBuKrygbCT0gC/J5XPE8cvaOujK9I/d9QG6rJVxJTRI3I=
X-Received: by 2002:a19:f013:: with SMTP id p19mr12738522lfc.36.1554790669149;
 Mon, 08 Apr 2019 23:17:49 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552921225.git.jrdr.linux@gmail.com> <CAFqt6zaV5zcc495BBk1Wi7p+zOF8y=P5KRfKkvwY=stagUFKWQ@mail.gmail.com>
In-Reply-To: <CAFqt6zaV5zcc495BBk1Wi7p+zOF8y=P5KRfKkvwY=stagUFKWQ@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 9 Apr 2019 11:47:37 +0530
Message-ID: <CAFqt6zbDk7OAdk-WXG50Frppny0DOpdwR1vnTS7pCpjf66j3aQ@mail.gmail.com>
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

Hi Andrew/ Michal,

On Mon, Apr 1, 2019 at 10:56 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Hi Andrew,
>
> On Tue, Mar 19, 2019 at 7:47 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> >
> > Previouly drivers have their own way of mapping range of
> > kernel pages/memory into user vma and this was done by
> > invoking vm_insert_page() within a loop.
> >
> > As this pattern is common across different drivers, it can
> > be generalized by creating new functions and use it across
> > the drivers.
> >
> > vm_map_pages() is the API which could be used to map
> > kernel memory/pages in drivers which has considered vm_pgoff.
> >
> > vm_map_pages_zero() is the API which could be used to map
> > range of kernel memory/pages in drivers which has not considered
> > vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
> >
> > We _could_ then at a later "fix" these drivers which are using
> > vm_map_pages_zero() to behave according to the normal vm_pgoff
> > offsetting simply by removing the _zero suffix on the function
> > name and if that causes regressions, it gives us an easy way to revert.
> >
> > Tested on Rockchip hardware and display is working fine, including talking
> > to Lima via prime.
> >
> > v1 -> v2:
> >         Few Reviewed-by.
> >
> >         Updated the change log in [8/9]
> >
> >         In [7/9], vm_pgoff is treated in V4L2 API as a 'cookie'
> >         to select a buffer, not as a in-buffer offset by design
> >         and it always want to mmap a whole buffer from its beginning.
> >         Added additional changes after discussing with Marek and
> >         vm_map_pages() could be used instead of vm_map_pages_zero().
> >
> > v2 -> v3:
> >         Corrected the documentation as per review comment.
> >
> >         As suggested in v2, renaming the interfaces to -
> >         *vm_insert_range() -> vm_map_pages()* and
> >         *vm_insert_range_buggy() -> vm_map_pages_zero()*.
> >         As the interface is renamed, modified the code accordingly,
> >         updated the change logs and modified the subject lines to use the
> >         new interfaces. There is no other change apart from renaming and
> >         using the new interface.
> >
> >         Patch[1/9] & [4/9], Tested on Rockchip hardware.
> >
> > v3 -> v4:
> >         Fixed build warnings on patch [8/9] reported by kbuild test robot.
> >
> > Souptick Joarder (9):
> >   mm: Introduce new vm_map_pages() and vm_map_pages_zero() API
> >   arm: mm: dma-mapping: Convert to use vm_map_pages()
> >   drivers/firewire/core-iso.c: Convert to use vm_map_pages_zero()
> >   drm/rockchip/rockchip_drm_gem.c: Convert to use vm_map_pages()
> >   drm/xen/xen_drm_front_gem.c: Convert to use vm_map_pages()
> >   iommu/dma-iommu.c: Convert to use vm_map_pages()
> >   videobuf2/videobuf2-dma-sg.c: Convert to use vm_map_pages()
> >   xen/gntdev.c: Convert to use vm_map_pages()
> >   xen/privcmd-buf.c: Convert to use vm_map_pages_zero()
>
> Is it fine to take these patches into mm tree for regression ?

v4 of this series has not received any further comments/ kbuild error
in last 8 weeks (including
the previously posted v4).

Any suggestion, if it safe to take these changes through mm tree ? or any
other tree is preferred ?

>
> >
> >  arch/arm/mm/dma-mapping.c                          | 22 ++----
> >  drivers/firewire/core-iso.c                        | 15 +---
> >  drivers/gpu/drm/rockchip/rockchip_drm_gem.c        | 17 +----
> >  drivers/gpu/drm/xen/xen_drm_front_gem.c            | 18 ++---
> >  drivers/iommu/dma-iommu.c                          | 12 +---
> >  drivers/media/common/videobuf2/videobuf2-core.c    |  7 ++
> >  .../media/common/videobuf2/videobuf2-dma-contig.c  |  6 --
> >  drivers/media/common/videobuf2/videobuf2-dma-sg.c  | 22 ++----
> >  drivers/xen/gntdev.c                               | 11 ++-
> >  drivers/xen/privcmd-buf.c                          |  8 +--
> >  include/linux/mm.h                                 |  4 ++
> >  mm/memory.c                                        | 81 ++++++++++++++++++++++
> >  mm/nommu.c                                         | 14 ++++
> >  13 files changed, 134 insertions(+), 103 deletions(-)
> >
> > --
> > 1.9.1
> >

