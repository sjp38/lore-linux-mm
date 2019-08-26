Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 319BEC3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:08:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 010232184D
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:08:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 010232184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BE9A6B0562; Mon, 26 Aug 2019 07:08:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86E946B0563; Mon, 26 Aug 2019 07:08:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ACD16B0564; Mon, 26 Aug 2019 07:08:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0249.hostedemail.com [216.40.44.249])
	by kanga.kvack.org (Postfix) with ESMTP id 58A476B0562
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:08:58 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 15A8A2659
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:08:58 +0000 (UTC)
X-FDA: 75864306756.11.arch92_6b5a4d8395108
X-HE-Tag: arch92_6b5a4d8395108
X-Filterd-Recvd-Size: 3279
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:08:57 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E9BAEAF23;
	Mon, 26 Aug 2019 11:08:55 +0000 (UTC)
Message-ID: <4d8d18af22d6dcd122bc9b4d9c2bd49e8443c746.camel@suse.de>
Subject: Re: [PATCH v2 10/11] arm64: edit zone_dma_bits to fine tune
 dma-direct min mask
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Christoph Hellwig <hch@lst.de>
Cc: catalin.marinas@arm.com, wahrenst@gmx.net, marc.zyngier@arm.com, 
 robh+dt@kernel.org, Robin Murphy <robin.murphy@arm.com>, 
 linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org, 
 linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org,
 linux-mm@kvack.org,  linux-riscv@lists.infradead.org,
 linux-kernel@vger.kernel.org,  phill@raspberryi.org, f.fainelli@gmail.com,
 will@kernel.org, eric@anholt.net,  mbrugger@suse.com,
 linux-rpi-kernel@lists.infradead.org,  akpm@linux-foundation.org,
 frowand.list@gmail.com, m.szyprowski@samsung.com
Date: Mon, 26 Aug 2019 13:08:50 +0200
In-Reply-To: <20190826070633.GB11331@lst.de>
References: <20190820145821.27214-1-nsaenzjulienne@suse.de>
	 <20190820145821.27214-11-nsaenzjulienne@suse.de>
	 <20190826070633.GB11331@lst.de>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-RvTUUUche1DA67AZeVhb"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-RvTUUUche1DA67AZeVhb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-08-26 at 09:06 +0200, Christoph Hellwig wrote:
> On Tue, Aug 20, 2019 at 04:58:18PM +0200, Nicolas Saenz Julienne wrote:
> > -	if (IS_ENABLED(CONFIG_ZONE_DMA))
> > +	if (IS_ENABLED(CONFIG_ZONE_DMA)) {
> >  		arm64_dma_phys_limit =3D max_zone_dma_phys();
> > +		zone_dma_bits =3D ilog2((arm64_dma_phys_limit - 1) &
> > GENMASK_ULL(31, 0)) + 1;
>
Hi Christoph,
thanks for the rewiews.

> This adds a way too long line.

I know, I couldn't find a way to split the operation without making it even
harder to read. I'll find a solution.

> I also find the use of GENMASK_ULL
> horribly obsfucating, but I know that opinion is't shared by everyone.

Don't have any preference so I'll happily change it. Any suggestions? Using=
 the
explicit 0xffffffffULL seems hard to read, how about SZ_4GB - 1?


--=-RvTUUUche1DA67AZeVhb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl1jvcIACgkQlfZmHno8
x/6y/wf/XTe7dlASMoYApyVt+lL6chBcap2r7MVKOVhCbC1oJQb7UdRyW7MVDO6k
gwdo2WmXqD3wUwhY5djX0adczLOJye1iGEdrrQfheRqm1rh07um3quT3TzgCSPat
OuX+vHuNsUE+3GyI+0OoOF0tu/TzOKJjgs4H645cnbuCaXbQFbL94yBctsDTF5hc
m4Bx+nksz99ddodUnw9CF4Ss5DPwkX23I3h7okwMMjvVuegIPUa9edppw3Za0Kby
k8b9QGCiMsGcwyq3+uSXTCq4iIU8reLTfvpZmVZ9QugMn8TkjjIQFyWS0HrXt2pz
r9iNomMe9w20W9Y9jS5Aj8bxByoK+Q==
=nQ/V
-----END PGP SIGNATURE-----

--=-RvTUUUche1DA67AZeVhb--


