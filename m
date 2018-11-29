Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF0E6B510C
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 01:04:49 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id s64-v6so261796lje.19
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 22:04:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w18sor204835lfe.13.2018.11.28.22.04.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 22:04:46 -0800 (PST)
MIME-Version: 1.0
References: <20181115154826.GA27948@jordon-HP-15-Notebook-PC>
 <CAFqt6zZy0-dy=a+KDrx7V1-j37pAVmt2r6bOkjgHwiopG-L+xA@mail.gmail.com> <5480157.mmjlM7ZeET@diego>
In-Reply-To: <5480157.mmjlM7ZeET@diego>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 29 Nov 2018 11:34:34 +0530
Message-ID: <CAFqt6zbqjFa-zS7TLx3Tcr3nvsdrbxsrOswWoh5xb_SoxPn98A@mail.gmail.com>
Subject: Re: [PATCH 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Stuebner <heiko@sntech.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, hjc@rock-chips.com, airlied@linux.ie, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org

On Wed, Nov 28, 2018 at 8:49 PM Heiko St=C3=BCbner <heiko@sntech.de> wrote:
>
> Hi Souptick,
>
> Am Montag, 26. November 2018, 06:36:42 CET schrieb Souptick Joarder:
> > On Thu, Nov 15, 2018 at 9:14 PM Souptick Joarder <jrdr.linux@gmail.com>
> wrote:
> > > Convert to use vm_insert_range() to map range of kernel
> > > memory to user vma.
> > >
> > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> >
> > Any feedback for this patch ?
>
> sorry, took a bit longer to find time for a test-run.
>
> Except the missing EXPORT_SYMBOL already pointed out in patch1,
> my displays are still working on modern (with iommu) and the older
> (without iommu) Rockchip socs, so
>
> On rk3188, rk3288, rk3328 and rk3399
> Tested-by: Heiko Stuebner <heiko@sntech.de>
> and in general
> Acked-by: Heiko Stuebner <heiko@sntech.de>

Thanks Heiko.
>
>
> Heiko
>
>
