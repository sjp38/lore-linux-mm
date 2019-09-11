Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BD8CECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40D6C20863
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:00:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40D6C20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBD4B6B0010; Wed, 11 Sep 2019 11:00:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6DA46B0266; Wed, 11 Sep 2019 11:00:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B83466B0269; Wed, 11 Sep 2019 11:00:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0155.hostedemail.com [216.40.44.155])
	by kanga.kvack.org (Postfix) with ESMTP id 907BD6B0010
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:00:06 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2DF0C1F35D
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:00:06 +0000 (UTC)
X-FDA: 75922950012.13.board64_cf33e41c533
X-HE-Tag: board64_cf33e41c533
X-Filterd-Recvd-Size: 4541
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:00:05 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F3045B81C;
	Wed, 11 Sep 2019 15:00:02 +0000 (UTC)
Message-ID: <bf00a6cba91936a89d4495d7f73b874afeac2cb3.camel@suse.de>
Subject: Re: [PATCH v5 3/4] arm64: use both ZONE_DMA and ZONE_DMA32
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: hch@lst.de, wahrenst@gmx.net, marc.zyngier@arm.com, robh+dt@kernel.org, 
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
 linux-riscv@lists.infradead.org, Will Deacon <will@kernel.org>, 
 f.fainelli@gmail.com, robin.murphy@arm.com, linux-kernel@vger.kernel.org, 
 mbrugger@suse.com, linux-rpi-kernel@lists.infradead.org,
 phill@raspberrypi.org,  m.szyprowski@samsung.com
Date: Wed, 11 Sep 2019 17:00:00 +0200
In-Reply-To: <20190911143527.GB43864@C02TF0J2HF1T.local>
References: <20190909095807.18709-1-nsaenzjulienne@suse.de>
	 <20190909095807.18709-4-nsaenzjulienne@suse.de>
	 <b0b824bebb9ef13ce746f9914de83126b0386e23.camel@suse.de>
	 <20190911143527.GB43864@C02TF0J2HF1T.local>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-p7TAQdIbBeJ5BGhbbxNM"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-p7TAQdIbBeJ5BGhbbxNM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-09-11 at 15:35 +0100, Catalin Marinas wrote:
> On Wed, Sep 11, 2019 at 12:54:38PM +0200, Nicolas Saenz Julienne wrote:
> > On Mon, 2019-09-09 at 11:58 +0200, Nicolas Saenz Julienne wrote:
> > >  /*
> > > - * Return the maximum physical address for ZONE_DMA32 (DMA_BIT_MASK(=
32)).
> > > It
> > > - * currently assumes that for memory starting above 4G, 32-bit devic=
es
> > > will
> > > - * use a DMA offset.
> > > + * Return the maximum physical address for a zone with a given addre=
ss
> > > size
> > > + * limit. It currently assumes that for memory starting above 4G, 32=
-bit
> > > + * devices will use a DMA offset.
> > >   */
> > > -static phys_addr_t __init max_zone_dma32_phys(void)
> > > +static phys_addr_t __init max_zone_phys(unsigned int zone_bits)
> > >  {
> > >         phys_addr_t offset =3D memblock_start_of_DRAM() & GENMASK_ULL=
(63,
> > > 32);
> > > -       return min(offset + (1ULL << 32), memblock_end_of_DRAM());
> > > +       return min(offset + (1ULL << zone_bits), memblock_end_of_DRAM=
());
> > >  }
> >=20
> > while testing other code on top of this series on odd arm64 machines I =
found
> > an
> > issue: when memblock_start_of_DRAM() !=3D 0, max_zone_phys() isn't taki=
ng into
> > account the offset to the beginning of memory. This doesn't matter with
> > zone_bits =3D=3D 32 but it does when zone_bits =3D=3D 30.
>=20
> I thought about this but I confused myself and the only case I had in
> mind was an AMD Seattle system with RAM starting at 4GB.

I found the issue on a Cavium ThunderX2 server. Oddly enough the memory sta=
rts
at 0x802f0000.

> What we need from this function is that the lowest naturally aligned
> 2^30 RAM is covered by ZONE_DMA while the rest to 2^32 are ZONE_DMA32.
> This assumed that devices only capable of 30-bit (or 32-bit), have the
> top address bits hardwired to be able access the bottom of the memory
> (and this would be expressed in DT as the DMA offset).

Ok, I was testing a fix I wrote under these assumptions...

> I guess the fix here is to use GENMASK_ULL(63, zone_bits).

...but this is way cleaner than my solution. Thanks!

Regards,
Nicolas


--=-p7TAQdIbBeJ5BGhbbxNM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl15C/AACgkQlfZmHno8
x/5f8ggAsuyzvV52JP8D4F3gMeBcgMlqN3+DQV47QfnPQoZyacvk5k1N3xUfcbNc
TnGiLoB3xsPta+yqccbFl2njg+FBjZc2Ja/+Natqxx+ulXxkIsp7eGP+yeWJiiw9
oUApF6wwL6WYXWn0H+ZoYfwjCFqUDGWuCUYP3K8vHSVytsTmYegU/B+9nvncBfmk
iF5Ql/Pd/TA0RLKvs2wftE8h889R2JSGWvdVMCIWWtC5qENC2ar2/ITluJ7kTCRX
9Ekkkh3L8fI6/qgPxKEcC8HuzO4aUTFlpWxxnfUMCd83wzWFWUUdOZ+rcaPpTMN2
ih1+8l3//QFXzpY5utTMqIWXxeKMKA==
=r2f7
-----END PGP SIGNATURE-----

--=-p7TAQdIbBeJ5BGhbbxNM--


