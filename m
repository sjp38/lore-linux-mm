Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id A66B16B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 11:36:30 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LZS004XSZGTE500@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Feb 2012 16:36:29 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZS00ETYZGS2F@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Feb 2012 16:36:28 +0000 (GMT)
Date: Wed, 22 Feb 2012 17:36:25 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv22 14/16] X86: integrate CMA with DMA-mapping subsystem
In-reply-to: <20120221161802.f6a28085.akpm@linux-foundation.org>
Message-id: <000101ccf180$1e5226b0$5af67410$%szyprowski@samsung.com>
Content-language: pl
References: <1329507036-24362-1-git-send-email-m.szyprowski@samsung.com>
 <1329507036-24362-15-git-send-email-m.szyprowski@samsung.com>
 <20120221161802.f6a28085.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>, 'Rob Clark' <rob.clark@linaro.org>, 'Ohad Ben-Cohen' <ohad@wizery.com>

Hi Andrew,

On Wednesday, February 22, 2012 1:18 AM Andrew Morton wrote:

> > This patch adds support for CMA to dma-mapping subsystem for x86
> > architecture that uses common pci-dma/pci-nommu implementation. This
> > allows to test CMA on KVM/QEMU and a lot of common x86 boxes.
> >
> > ...
> >
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -31,6 +31,7 @@ config X86
> >  	select ARCH_WANT_OPTIONAL_GPIOLIB
> >  	select ARCH_WANT_FRAME_POINTERS
> >  	select HAVE_DMA_ATTRS
> > +	select HAVE_DMA_CONTIGUOUS if !SWIOTLB
> >  	select HAVE_KRETPROBES
> >  	select HAVE_OPTPROBES
> >  	select HAVE_FTRACE_MCOUNT_RECORD
> 
> I don't think it's compilable at all for x86_64, because that platform
> selects SWIOTLB.

Right, x86 support is very basic, mainly for being able to test it on standard 
configuration with QEmu.

> After a while I got it to compile for i386.  arm didn't go so well,
> partly because arm allmodconfig is presently horked (something to do
> with Kconfig not setting PHYS_OFFSET) and partly because arm defconfig
> doesn't permit CMA to be set.  Got bored, gave up.

I think that all*config are broken on ARM. To enable CMA compilation, one need to 
select a subplatform based on ARMv6+ - for example one can start from 
arch/arm/configs/exynos4_defconfig and then use oldnoconfig.

> The patchset collides pretty seriously with pending dma api changes and
> pending arm changes in linux-next, so I didn't apply anything.  This
> will all need to be looked at, please.
> 
> I'll make do with reading the patches for now ;)

I've rebased the CMA patchset on top of next-20120222 kernel tree and I will send 
them soon as v23.

I hope this will help getting them merged to your tree. If I should select different
base for the patches, just let me know.

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
