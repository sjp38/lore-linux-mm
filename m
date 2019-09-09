Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83CEAC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 19:50:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 505E2207FC
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 19:50:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 505E2207FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEBA16B0007; Mon,  9 Sep 2019 15:50:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9BC96B0008; Mon,  9 Sep 2019 15:50:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB0826B000A; Mon,  9 Sep 2019 15:50:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0186.hostedemail.com [216.40.44.186])
	by kanga.kvack.org (Postfix) with ESMTP id A41E46B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:50:54 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 50102AC1C
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 19:50:54 +0000 (UTC)
X-FDA: 75916425228.23.cast98_5f22364996b27
X-HE-Tag: cast98_5f22364996b27
X-Filterd-Recvd-Size: 5339
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 19:50:53 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A1671B6D8;
	Mon,  9 Sep 2019 19:50:51 +0000 (UTC)
Message-ID: <cac63db8b9a7ff78fc0cd816c7dce284a06480d5.camel@suse.de>
Subject: Re: [PATCH v5 0/4] Raspberry Pi 4 DMA addressing support
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Stefan Wahren <wahrenst@gmx.net>, catalin.marinas@arm.com, hch@lst.de, 
 marc.zyngier@arm.com, robh+dt@kernel.org,
 linux-arm-kernel@lists.infradead.org,  linux-mm@kvack.org,
 linux-riscv@lists.infradead.org
Cc: f.fainelli@gmail.com, will@kernel.org, linux-kernel@vger.kernel.org, 
 mbrugger@suse.com, linux-rpi-kernel@lists.infradead.org,
 phill@raspberrypi.org,  robin.murphy@arm.com, m.szyprowski@samsung.com
Date: Mon, 09 Sep 2019 21:50:47 +0200
In-Reply-To: <5a8af6e9-6b90-ce26-ebd7-9ee626c9fa0e@gmx.net>
References: <20190909095807.18709-1-nsaenzjulienne@suse.de>
	 <5a8af6e9-6b90-ce26-ebd7-9ee626c9fa0e@gmx.net>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-aEBb/xch/kbKDpnAu5z0"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-aEBb/xch/kbKDpnAu5z0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-09-09 at 21:33 +0200, Stefan Wahren wrote:
> Hi Nicolas,
>=20
> Am 09.09.19 um 11:58 schrieb Nicolas Saenz Julienne:
> > Hi all,
> > this series attempts to address some issues we found while bringing up
> > the new Raspberry Pi 4 in arm64 and it's intended to serve as a follow
> > up of these discussions:
> > v4: https://lkml.org/lkml/2019/9/6/352
> > v3: https://lkml.org/lkml/2019/9/2/589
> > v2: https://lkml.org/lkml/2019/8/20/767
> > v1: https://lkml.org/lkml/2019/7/31/922
> > RFC: https://lkml.org/lkml/2019/7/17/476
> >=20
> > The new Raspberry Pi 4 has up to 4GB of memory but most peripherals can
> > only address the first GB: their DMA address range is
> > 0xc0000000-0xfc000000 which is aliased to the first GB of physical
> > memory 0x00000000-0x3c000000. Note that only some peripherals have thes=
e
> > limitations: the PCIe, V3D, GENET, and 40-bit DMA channels have a wider
> > view of the address space by virtue of being hooked up trough a second
> > interconnect.
> >=20
> > Part of this is solved on arm32 by setting up the machine specific
> > '.dma_zone_size =3D SZ_1G', which takes care of reserving the coherent
> > memory area at the right spot. That said no buffer bouncing (needed for
> > dma streaming) is available at the moment, but that's a story for
> > another series.
> >=20
> > Unfortunately there is no such thing as 'dma_zone_size' in arm64. Only
> > ZONE_DMA32 is created which is interpreted by dma-direct and the arm64
> > arch code as if all peripherals where be able to address the first 4GB
> > of memory.
> >=20
> > In the light of this, the series implements the following changes:
> >=20
> > - Create both DMA zones in arm64, ZONE_DMA will contain the first 1G
> >   area and ZONE_DMA32 the rest of the 32 bit addressable memory. So far
> >   the RPi4 is the only arm64 device with such DMA addressing limitation=
s
> >   so this hardcoded solution was deemed preferable.
> >=20
> > - Properly set ARCH_ZONE_DMA_BITS.
> >=20
> > - Reserve the CMA area in a place suitable for all peripherals.
> >=20
> > This series has been tested on multiple devices both by checking the
> > zones setup matches the expectations and by double-checking physical
> > addresses on pages allocated on the three relevant areas GFP_DMA,
> > GFP_DMA32, GFP_KERNEL:
> >=20
> > - On an RPi4 with variations on the ram memory size. But also forcing
> >   the situation where all three memory zones are nonempty by setting a =
3G
> >   ZONE_DMA32 ceiling on a 4G setup. Both with and without NUMA support.
> >=20
> i like to test this series on Raspberry Pi 4 and i have some questions
> to get arm64 running:
>=20
> Do you use U-Boot? Which tree?

No, I boot directly.

> Are there any config.txt tweaks necessary?

I'm using the foundation's arm64 stub. Though I'm not 100% it's needed anym=
ore
with the latest firmware.

config.txt:
	arm_64bit=3D1
	armstub=3Darmstub8-gic.bin
	enable_gic=3D1
	enable_uart=3D1

Apart from that the series is based on today's linux-next plus your RPi4
bringup patches.


--=-aEBb/xch/kbKDpnAu5z0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl12rRcACgkQlfZmHno8
x/7toQf+L/Ta9MCsjv+DyfWvjt/fl9GT60+Z9cBctuHCujlRmElfGztMgn6Nu0hh
fosUsadksYqFzrdw9GLfqJj57Lmq8RXvt/glSBSN0lQZkXjn3pVklko/Wkj2UOaH
SvICcPMWlbk6nRjyVzX70aenvVmV5BqYa6qNxuCxPHEkYeVd9egxB//JPjtL6tqK
4QVSoJLjfoQAlYNWDm96f77nn5doyj1ibooZxaFQe5u0+3T0ytqCZfgDsJvrIpuW
2E4fth6VMA1AOFYH+EsvU49WyLcA1ry6xEA5NbkfmZZdh1eSyW7nCcCT60+S7Zm5
kfIX5VMaPvFiHYUMyyPzrdRP1un7VA==
=oHYd
-----END PGP SIGNATURE-----

--=-aEBb/xch/kbKDpnAu5z0--


