Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 169DD6B0068
	for <linux-mm@kvack.org>; Sat, 29 Dec 2012 01:53:51 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bh2so6356461pad.5
        for <linux-mm@kvack.org>; Fri, 28 Dec 2012 22:53:50 -0800 (PST)
Date: Fri, 28 Dec 2012 22:53:56 -0800
From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] arm: dma mapping: export arm iommu functions
Message-ID: <20121229065356.GA13760@quad.lixom.net>
References: <1356592458-11077-1-git-send-email-prathyush.k@samsung.com>
 <50DC580C.7080507@samsung.com>
 <CAH=HWYP5r18qjQSc_2121vikbTMpYv6DKOfW=hpOpGB7rUyNRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH=HWYP5r18qjQSc_2121vikbTMpYv6DKOfW=hpOpGB7rUyNRA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prathyush K <prathyush@chromium.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Prathyush K <prathyush.k@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

On Fri, Dec 28, 2012 at 09:53:47AM +0530, Prathyush K wrote:
> On Thu, Dec 27, 2012 at 7:45 PM, Marek Szyprowski
> <m.szyprowski@samsung.com>wrote:
> 
> > Hello,
> >
> >
> > On 12/27/2012 8:14 AM, Prathyush K wrote:
> >
> >> This patch adds EXPORT_SYMBOL calls to the three arm iommu
> >> functions - arm_iommu_create_mapping, arm_iommu_free_mapping
> >> and arm_iommu_attach_device. These functions can now be called
> >> from dynamic modules.
> >>
> >
> > Could You describe a bit more why those functions might be needed by
> > dynamic modules?
> >
> > Hi Marek,
> 
> We are adding iommu support to exynos gsc and s5p-mfc.
> And these two drivers need to be built as modules to improve boot time.
> 
> We're calling these three functions from inside these drivers:
> e.g.
> mapping = arm_iommu_create_mapping(&platform_bus_type, 0x20000000, SZ_256M,
> 4);
> arm_iommu_attach_device(mdev, mapping);

The driver shouldn't have to call these low-level functions directly,
something's wrong if you need that.

How is the DMA address management different here from other system/io mmus? is
that 256M window a hardware restriction?

-Olof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
