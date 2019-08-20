Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22B7CC3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 17:27:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E580122DD3
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 17:27:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E580122DD3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FF626B0006; Tue, 20 Aug 2019 13:27:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AFDB6B0007; Tue, 20 Aug 2019 13:27:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C64A6B0008; Tue, 20 Aug 2019 13:27:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0239.hostedemail.com [216.40.44.239])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8456B0006
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:27:55 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 08E58180AD803
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 17:27:55 +0000 (UTC)
X-FDA: 75843488910.26.cars99_adc4655e5f49
X-HE-Tag: cars99_adc4655e5f49
X-Filterd-Recvd-Size: 4028
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 17:27:54 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1272AABBE;
	Tue, 20 Aug 2019 17:27:53 +0000 (UTC)
Message-ID: <ef3eaf8ea03ae8dc86a1a2f293087ff5c2f56b7a.camel@suse.de>
Subject: Re: [PATCH v2 03/11] of/fdt: add of_fdt_machine_is_compatible
 function
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: Rob Herring <robh+dt@kernel.org>
Cc: "open list:GENERIC INCLUDE/ASM HEADER FILES"
 <linux-arch@vger.kernel.org>,  devicetree@vger.kernel.org, "moderated
 list:BROADCOM BCM2835 ARM ARCHITECTURE"
 <linux-rpi-kernel@lists.infradead.org>, Florian Fainelli
 <f.fainelli@gmail.com>,  Andrew Morton <akpm@linux-foundation.org>, Frank
 Rowand <frowand.list@gmail.com>, Eric Anholt <eric@anholt.net>,  Marc
 Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will@kernel.org>,  "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux IOMMU
 <iommu@lists.linux-foundation.org>, Matthias Brugger <mbrugger@suse.com>, 
 Stefan Wahren <wahrenst@gmx.net>, linux-riscv@lists.infradead.org, Marek
 Szyprowski <m.szyprowski@samsung.com>,  Robin Murphy
 <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, "moderated
 list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE"
 <linux-arm-kernel@lists.infradead.org>, phill@raspberryi.org
Date: Tue, 20 Aug 2019 19:27:50 +0200
In-Reply-To: <CAL_JsqJT3UNVKpAt+3g-tosy=uCZTosUxD4RfVYjMJ-gpGmPiA@mail.gmail.com>
References: <20190820145821.27214-1-nsaenzjulienne@suse.de>
	 <20190820145821.27214-4-nsaenzjulienne@suse.de>
	 <CAL_JsqJT3UNVKpAt+3g-tosy=uCZTosUxD4RfVYjMJ-gpGmPiA@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Cm+dM0aB2YImXVa0ovlW"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-Cm+dM0aB2YImXVa0ovlW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Rob,
thanks for the rewiew.

On Tue, 2019-08-20 at 12:16 -0500, Rob Herring wrote:
> On Tue, Aug 20, 2019 at 9:58 AM Nicolas Saenz Julienne
> <nsaenzjulienne@suse.de> wrote:
> > Provides the same functionality as of_machine_is_compatible.
> >=20
> > Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
> > ---
> >=20
> > Changes in v2: None
> >=20
> >  drivers/of/fdt.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> >=20
> > diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> > index 9cdf14b9aaab..06ffbd39d9af 100644
> > --- a/drivers/of/fdt.c
> > +++ b/drivers/of/fdt.c
> > @@ -802,6 +802,13 @@ const char * __init of_flat_dt_get_machine_name(vo=
id)
> >         return name;
> >  }
> >=20
> > +static const int __init of_fdt_machine_is_compatible(char *name)
>=20
> No point in const return (though name could possibly be const), and
> the return could be bool instead.

Sorry, I completely missed that const, shouldn't have been there to begin w=
ith.

I'll add a const to the name argument and return a bool on the next version=
.

Regards,
Nicolas



--=-Cm+dM0aB2YImXVa0ovlW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEErOkkGDHCg2EbPcGjlfZmHno8x/4FAl1cLZYACgkQlfZmHno8
x/4DowgAjoLUq0qUOWOtkTx0OcxyQrKy++gIvChR7IajK1yXJKyT8kA/QNZrERqj
nvLlebXPhJG0y4uUTzEVmzsgUFS4vopZAzL+H7TGfXsL8pQbGjnO+l62gc1oqTVd
U+IrQWs0BPZ/MeCxUXUtKlYdMMuf9Ld8z16siDZPj5pYY6IHq8HtS1WseTvTti6S
pHpXyK+XiPpxzupgUjNm6Lzsm8FO0P2tw5IKD3vRLS+4vLaYUPieCLdMvkf1lMU6
DkQ71pEENpt35eBer1lLK/meYuisvK4V+tnwrWSDGZCuywbhi1fpvAyh3CRicE3t
rvLGmR2JEXsldgQeodOoEyKoeWSAgQ==
=hgaN
-----END PGP SIGNATURE-----

--=-Cm+dM0aB2YImXVa0ovlW--


