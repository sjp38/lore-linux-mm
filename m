Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3C256B4D97
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 10:19:58 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id g3so3006291wmf.1
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 07:19:58 -0800 (PST)
Received: from gloria.sntech.de (gloria.sntech.de. [185.11.138.130])
        by mx.google.com with ESMTPS id z7si5977588wrq.360.2018.11.28.07.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Nov 2018 07:19:57 -0800 (PST)
From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
Date: Wed, 28 Nov 2018 16:19:41 +0100
Message-ID: <5480157.mmjlM7ZeET@diego>
In-Reply-To: <CAFqt6zZy0-dy=a+KDrx7V1-j37pAVmt2r6bOkjgHwiopG-L+xA@mail.gmail.com>
References: <20181115154826.GA27948@jordon-HP-15-Notebook-PC> <CAFqt6zZy0-dy=a+KDrx7V1-j37pAVmt2r6bOkjgHwiopG-L+xA@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, hjc@rock-chips.com, airlied@linux.ie, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org

Hi Souptick,

Am Montag, 26. November 2018, 06:36:42 CET schrieb Souptick Joarder:
> On Thu, Nov 15, 2018 at 9:14 PM Souptick Joarder <jrdr.linux@gmail.com> 
wrote:
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> > 
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> 
> Any feedback for this patch ?

sorry, took a bit longer to find time for a test-run.

Except the missing EXPORT_SYMBOL already pointed out in patch1,
my displays are still working on modern (with iommu) and the older
(without iommu) Rockchip socs, so

On rk3188, rk3288, rk3328 and rk3399
Tested-by: Heiko Stuebner <heiko@sntech.de>
and in general
Acked-by: Heiko Stuebner <heiko@sntech.de>


Heiko
