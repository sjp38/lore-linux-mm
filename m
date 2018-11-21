Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 461AD6B274F
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 14:57:06 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id j24-v6so2109071lji.20
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 11:57:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x82sor11254640lff.40.2018.11.21.11.57.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 11:57:04 -0800 (PST)
MIME-Version: 1.0
References: <20181115154314.GA27850@jordon-HP-15-Notebook-PC>
 <CAFqt6zZGP5DnAQd_19xKcLezOYaLsZpPr=FGxiTb7JRjTEJ4cA@mail.gmail.com> <0c6f1144-6ee0-29df-5e1f-d35d2264e06e@oracle.com>
In-Reply-To: <0c6f1144-6ee0-29df-5e1f-d35d2264e06e@oracle.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 22 Nov 2018 01:26:51 +0530
Message-ID: <CAFqt6zavi-S9ySZJTKG9zChacSD+ZCOVyyW71B1DfjggTH=Jkg@mail.gmail.com>
Subject: Re: [PATCH 0/9] Use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Thu, Nov 22, 2018 at 1:08 AM Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
> On 11/21/18 1:24 AM, Souptick Joarder wrote:
> > On Thu, Nov 15, 2018 at 9:09 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> >> Previouly drivers have their own way of mapping range of
> >> kernel pages/memory into user vma and this was done by
> >> invoking vm_insert_page() within a loop.
> >>
> >> As this pattern is common across different drivers, it can
> >> be generalized by creating a new function and use it across
> >> the drivers.
> >>
> >> vm_insert_range is the new API which will be used to map a
> >> range of kernel memory/pages to user vma.
> >>
> >> All the applicable places are converted to use new vm_insert_range
> >> in this patch series.
> >>
> >> Souptick Joarder (9):
> >>   mm: Introduce new vm_insert_range API
> >>   arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
> >>   drivers/firewire/core-iso.c: Convert to use vm_insert_range
> >>   drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
> >>   drm/xen/xen_drm_front_gem.c: Convert to use vm_insert_range
> >>   iommu/dma-iommu.c: Convert to use vm_insert_range
> >>   videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range
> >>   xen/gntdev.c: Convert to use vm_insert_range
> >>   xen/privcmd-buf.c: Convert to use vm_insert_range
> > Any further comment on driver changes ?
>
> Xen drivers (the last two patches) look fine to me.

Thanks, can I considered this as Reviewed-by ?

>
> -boris
>
>
> >>  arch/arm/mm/dma-mapping.c                         | 21 ++++++-----------
> >>  drivers/firewire/core-iso.c                       | 15 ++----------
> >>  drivers/gpu/drm/rockchip/rockchip_drm_gem.c       | 20 ++--------------
> >>  drivers/gpu/drm/xen/xen_drm_front_gem.c           | 20 +++++-----------
> >>  drivers/iommu/dma-iommu.c                         | 12 ++--------
> >>  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 ++++++-------------
> >>  drivers/xen/gntdev.c                              | 11 ++++-----
> >>  drivers/xen/privcmd-buf.c                         |  8 ++-----
> >>  include/linux/mm_types.h                          |  3 +++
> >>  mm/memory.c                                       | 28 +++++++++++++++++++++++
> >>  mm/nommu.c                                        |  7 ++++++
> >>  11 files changed, 70 insertions(+), 98 deletions(-)
> >>
> >> --
> >> 1.9.1
> >>
>
