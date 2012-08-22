Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 44DEB6B0069
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 10:45:11 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Wed, 22 Aug 2012 16:44:29 +0200
Subject: Re: [RFC 0/4] ARM: dma-mapping: IOMMU atomic allocation
Message-ID: <20120822.174429.909991514856769456.hdoyu@nvidia.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com><005901cd805e$4afd2e40$e0f78ac0$%szyprowski@samsung.com>
In-Reply-To: <005901cd805e$4afd2e40$e0f78ac0$%szyprowski@samsung.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

Hi Marek,

Marek Szyprowski <m.szyprowski@samsung.com> wrote @ Wed, 22 Aug 2012 14:04:=
26 +0200:

> Hi Hiroshi,
>=20
> On Wednesday, August 22, 2012 12:20 PM Hiroshi Doyu wrote:
>=20
> > The commit e9da6e9 "ARM: dma-mapping: remove custom consistent dma
> > region" breaks the compatibility with existing drivers. This causes
> > the following kernel oops(*1). That driver has called dma_pool_alloc()
> > to allocate memory from the interrupt context, and it hits
> > BUG_ON(in_interrpt()) in "get_vm_area_caller()". This patch seris
> > fixes this problem with making use of the pre-allocate atomic memory
> > pool which DMA is using in the same way as DMA does now.
> >=20
> > Any comment would be really appreciated.
>=20
> I was working on the similar patches, but You were faster. ;-)

Thank you for reviewing my patches.

> Basically the patch no 1 and 2 are fine, but I don't like the changes pro=
posed in=20
> patch 3 and 4. You should not alter the attributes provided by the user n=
or make any
> assumptions that such attributes has been provided - drivers are allowed =
to call=20
> dma_alloc_attrs() directly. Please rework your patches to avoid such
> approach.

Sure. I'll send the series again later.

Instead of making use of DMA_ATTR_NO_KERNEL_MAPPING, I use the
following "__in_atomic_pool()" to see if buffer comes from atomic or
not at freeing.
