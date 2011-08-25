Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 331186B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 03:25:08 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LQH00C1939UL940@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 25 Aug 2011 08:25:06 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LQH00B6J39TZG@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 25 Aug 2011 08:25:05 +0100 (BST)
Date: Thu, 25 Aug 2011 09:22:18 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 8/8] ARM: S5PV210: example of CMA private area for FIMC
 device on Goni board
In-reply-to: 
 <CAKnK67RcMAt6j3CEi2Z7QTN42v07LDCfa_T38F9-5b97TJ0-hA@mail.gmail.com>
Message-id: <01d801cc62f7$b9041b40$2b0c51c0$%szyprowski@samsung.com>
Content-language: pl
References: <CAKnK67RcMAt6j3CEi2Z7QTN42v07LDCfa_T38F9-5b97TJ0-hA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Aguirre, Sergio'" <saaguirre@ti.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>

Hello,

On Wednesday, August 24, 2011 5:41 PM Aguirre, Sergio wrote:

> On Fri, Aug 19, 2011 at 04:27:44PM +0200, Marek Szyprowski wrote:
> > This patch is an example how device private CMA area can be activated.
> > It creates one CMA region and assigns it to the first s5p-fimc device on
> > Samsung Goni S5PC110 board.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  arch/arm/mach-s5pv210/mach-goni.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > diff --git a/arch/arm/mach-s5pv210/mach-goni.c b/arch/arm/mach-s5pv210/mach-
> goni.c
> > index 14578f5..f766c45 100644
> > --- a/arch/arm/mach-s5pv210/mach-goni.c
> > +++ b/arch/arm/mach-s5pv210/mach-goni.c
> > @@ -26,6 +26,7 @@
> >  #include <linux/input.h>
> >  #include <linux/gpio.h>
> >  #include <linux/interrupt.h>
> > +#include <linux/dma-contiguous.h>
> >
> >  #include <asm/mach/arch.h>
> >  #include <asm/mach/map.h>
> > @@ -857,6 +858,9 @@ static void __init goni_map_io(void)
> >  static void __init goni_reserve(void)
> >  {
> >  	s5p_mfc_reserve_mem(0x43000000, 8 << 20, 0x51000000, 8 << 20);
> > +
> > +	/* Create private 16MiB contiguous memory area for s5p-fimc.0 device */
> > +	dma_declare_contiguous(&s5p_device_fimc0.dev, 16*SZ_1M, 0);
> 
> This is broken, since according to patch #0006, dma_declare_contiguous
requires
> a 4th param (limit) which you're not providing here.

You are definitely right, there should be one more parameter. This patch was
just
cherry-picked from older version just before posting to mailing lists. I'm
really
sorry for this trivial bug.
 
Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
