Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id BB2996B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 02:41:05 -0400 (EDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Wed, 19 Sep 2012 23:40:36 -0700
Subject: RE: [RFC 0/5] ARM: dma-mapping: New dma_map_ops to control IOVA
 more precisely
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E379FDC1F2D@HQMAIL04.nvidia.com>
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
 <20120918124918.GK2505@amd.com>
 <20120919095843.d1db155e0f085f4fcf64ea32@nvidia.com>
 <201209190759.46174.arnd@arndb.de> <20120919125020.GQ2505@amd.com>
 <401E54CE964CD94BAE1EB4A729C7087E379FDC1EEB@HQMAIL04.nvidia.com>
 <505A7DB4.4090902@wwwdotorg.org>
In-Reply-To: <505A7DB4.4090902@wwwdotorg.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Cc: Joerg Roedel <joerg.roedel@amd.com>, Arnd Bergmann <arnd@arndb.de>, Hiroshi Doyu <hdoyu@nvidia.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

> > On Tegra, the following use cases need specific IOVA mapping.
> > 1. Few MMIO blocks need IOVA=3DPA mapping setup.
>=20
> In that case, why would we enable the IOMMU for that one device; IOMMU
> disabled means VA=3D=3DPA, right? Perhaps isolation of the device so it c=
an only
> access certain PA ranges for security?

The device(H/W controller) need to access few special memory blocks(IOVA=3D=
=3DPA)
and DRAM as well. If IOMMU is disabled, then it has to handle memory fragme=
ntation,
 which defeats the purpose of IOMMU support.
There is also a case where frame buffer memory is passed from BootLoader to=
 Kernel and
display H/W  continues to access it with IOMMU enabled. To support this, th=
e one to one
mapping has to be setup before enabling IOMMU.

-KR



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
