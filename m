Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 848406B0072
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 14:16:37 -0400 (EDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Fri, 21 Sep 2012 11:16:00 -0700
Subject: RE: [RFC 0/5] ARM: dma-mapping: New dma_map_ops to control IOVA
 more precisely
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E379FDC2372@HQMAIL04.nvidia.com>
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
 <20120918124918.GK2505@amd.com>
 <20120919095843.d1db155e0f085f4fcf64ea32@nvidia.com>
 <201209190759.46174.arnd@arndb.de> <20120919125020.GQ2505@amd.com>
 <401E54CE964CD94BAE1EB4A729C7087E379FDC1EEB@HQMAIL04.nvidia.com>
 <505A7DB4.4090902@wwwdotorg.org>
 <401E54CE964CD94BAE1EB4A729C7087E379FDC1F2D@HQMAIL04.nvidia.com>
 <505B35F7.2080201@wwwdotorg.org>
In-Reply-To: <505B35F7.2080201@wwwdotorg.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Cc: Joerg Roedel <joerg.roedel@amd.com>, Arnd Bergmann <arnd@arndb.de>, Hiroshi Doyu <hdoyu@nvidia.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

> > The device(H/W controller) need to access few special memory
> > blocks(IOVA=3D=3DPA) and DRAM as well.
>=20
> OK, so only /some/ of the VA space is VA=3D=3DPA, and some is remapped; t=
hat's a
> little different that what you originally implied above.
>=20
> BTW, which HW module is this; AVP/COP or something else. This sounds like=
 an
> odd requirement.

This is not specific to ARM7. There are protected memory regions on Tegra t=
hat
can be accessed by some controllers like display, 2D, 3D, VDE, HDA. These a=
re
DRAM regions configured as protected by BootRom. These memory regions
are not exposed to and not managed by OS page allocator. The H/W controller
 accesses to these regions still to go through IOMMU.
The IOMMU view for all the H/W controllers is not uniform on Tegra.
Some Controllers see entire 4GB IOVA space. i.e all accesses go though IOMM=
U.
Some controllers see the IOVA Space that don't overlap with MMIO space.  i.=
e
The MMIO address access bypass IOMMU and directly go to MMIO space.
Tegra IOMMU can support multiple address spaces as well. To hide controller
Specific behavior, the drivers should take care of one to one mapping and
remove inaccessible iova spaces in their address space's based platform dev=
ice info.

In my initial mail, I referred protected memory regions as MMIO blocks, whi=
ch
is incorrect.




-KR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
