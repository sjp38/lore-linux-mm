Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB1F6B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:53:04 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 63so1897841wrn.7
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:53:04 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id 44si2694418wrb.187.2018.02.21.08.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 08:53:03 -0800 (PST)
Date: Wed, 21 Feb 2018 17:52:57 +0100
From: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: Re: [PATCH 0/6] DISCONTIGMEM support for PPC32
Message-ID: <20180221165257.kyf35ifr4ndblowt@latitude>
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
 <193a407d-e6b8-9e29-af47-3d401b6414a0@c-s.fr>
 <20180221144240.pfu2run3pixt3pzo@latitude>
 <a36983ec-5e97-e968-8143-1b2615ea55f8@c-s.fr>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="okldkbspm4p3rco7"
Content-Disposition: inline
In-Reply-To: <a36983ec-5e97-e968-8143-1b2615ea55f8@c-s.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>
Cc: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org, Joel Stanley <joel@jms.id.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--okldkbspm4p3rco7
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 21, 2018 at 04:02:25PM +0100, Christophe LEROY wrote:
[...]
> > > My question might me stupid, as I don't know PCC64 in deep, but when =
looking
> > > at page_is_ram() in arch/powerpc/mm/mem.c, I have the feeling the PPC=
64
> > > implements ram by blocks. Isn't it what you are trying to achieve ? W=
ouldn't
> > > it be feasible to map to what's done in PPC64 for PPC32 ?
> >=20
> > Using page_is_ram in __ioremap_caller and the same memblock-based
> > approach that's used on PPC64 on PPC32 *should* work, but I think due to
> > the following line in initmem_init, it won't:
> >=20
> > 	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);
>=20
> Can't we just fix that ?

I'll give it a try.


Thanks,
Jonathan Neusch=C3=A4fer

--okldkbspm4p3rco7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJajaPhAAoJEAgwRJqO81/b+aAP/A8ieDpgUlAvsfT1R0W2JTwZ
fWSbAAewS0RNzEyDXJMKuhPHPIFsed0oBGKLd2MelE0DPqIqAab+nC8gtXjFWcWT
ze47sr01w+ePMhnX3UtVT71WFXMYlYder8iaj3CTBtNFSAZlt7hgouHFRDuqXos9
IogPzpgqsHml/4rOP0Qr/i9EKmCeXOKW4jRI3xTxTOUlaJaxbWUky+7CofvxRXpc
quq3ljk6SlBXeiZuskiN9u3g7h1uBfRXsl50QH/XrRaMZB5xVyzUSbT5hSHdmI1b
F/XS54jsZVFN0PcUOTg8E5XuLYA9/fZPxk/9+XwrI854VU5Br9qFmCW4grwsMIVE
efJEft6/2LRlZsLh2M/iJKNJ7isFKbzwI96x5SqT0lpY2QdrXYrlTWlWQY9UpMIY
urWQxOPogQ1LCqgKyi7aTBcWJh5VQ/imU4a91SancINfUMu0fpGkdquhCFLoLpTK
ZvkzsRJdLoy/urFxXFoWOsIeiz0MoHPW7dCfU9qZx/7jj3DQojqBxtltmrVXZdEc
bgOTMGGiYe2E6cbA6pXgVCNpbL0VqEzlc8Wkb3AQQCQbvZf+A5y1bLp7boHRD91z
zsmDfdCDxkbXqNhSKaBSwlO9zQIElbPauoidd2zDu3WBPH0CLPMr7P1o63By7HKA
6t8sFNQ2NavTaYaFH6Ij
=H5py
-----END PGP SIGNATURE-----

--okldkbspm4p3rco7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
