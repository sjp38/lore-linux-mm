Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id CB9396B0089
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 01:45:44 -0500 (EST)
Date: Thu, 29 Nov 2012 08:45:15 +0200
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: Re: [PATCH 1/1] ARM: tegra: bus_notifier registers IOMMU
 devices(was: How to specify IOMMU'able devices in DT)
Message-ID: <20121129084515.8a818bf4793e0d4bb3305c36@nvidia.com>
In-Reply-To: <50B652F2.5050407@wwwdotorg.org>
References: <20120924124452.41070ed2ee9944d930cffffc@nvidia.com>
	<054901cd9a45$db1a7ea0$914f7be0$%szyprowski@samsung.com>
	<20120924.145014.1452596970914043018.hdoyu@nvidia.com>
	<20121128.154832.539666140149950229.hdoyu@nvidia.com>
	<50B652F2.5050407@wwwdotorg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "joro@8bytes.org" <joro@8bytes.org>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "arnd@arndb.de" <arnd@arndb.de>, Krishna Reddy <vdumpa@nvidia.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, 28 Nov 2012 19:07:46 +0100
Stephen Warren <swarren@wwwdotorg.org> wrote:
......
> >>> Please read more about bus notifiers. IMHO a good example is provided in 
> >>> the following thread:
> >>> http://www.mail-archive.com/linux-samsung-soc@vger.kernel.org/msg12238.html
> >>
> >> This bus notifier seems enough flexible to afford the variation of
> >> IOMMU map info, like Tegra ASID, which could be platform-specific, and
> >> the other could be common too. There's already iommu_bus_notifier
> >> too. I'll try to implement something base on this.
> > 
> > Experimentally implemented as below. With the followig patch, each
> > device could specify its own map in DT, and automatically the device
> > would be attached to the map.
> > 
> > There is a case that some devices share a map. This patch doesn't
> > suppor such case yet.
> > 
> > From 8cb75bb6f3a8535a077e0e85265f87c1f1289bfd Mon Sep 17 00:00:00 2001
> > From: Hiroshi Doyu <hdoyu@nvidia.com>
> > Date: Wed, 28 Nov 2012 14:47:04 +0200
> > Subject: [PATCH 1/1] ARM: tegra: bus_notifier registers IOMMU devices
> > 
> > platform_bus notifier registers IOMMU devices if dma-window is
> > specified.
> > 
> > Its format is:
> >   dma-window = <"start" "size">;
> > ex)
> >   dma-window = <0x12345000 0x8000>;
> > 
> > Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> > ---
> >  arch/arm/mach-tegra/board-dt-tegra30.c |   40 ++++++++++++++++++++++++++++++++
> 
> Shouldn't this patch be to the IOMMU driver itself, not the core Tegra code?

That could be possible and cleaner. I'll check if it works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
