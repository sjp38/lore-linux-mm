Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8226B02C3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 19:21:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f127so13057480pgc.10
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 16:21:27 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id m16si913486plk.280.2017.06.26.16.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 16:21:26 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id e199so2177409pfh.0
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 16:21:26 -0700 (PDT)
Date: Tue, 27 Jun 2017 07:21:24 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 1/4] mm/hotplug: aligne the hotplugable range with
 memory_block
Message-ID: <20170626232124.GC53180@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-2-richard.weiyang@gmail.com>
 <be965d3a-002b-9a9f-873b-b7237238ac21@nvidia.com>
 <20170626002006.GA47120@WeideMacBook-Pro.local>
 <35dd30c8-b31d-b8da-903a-0ea7eafb7e04@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="XWOWbaMNXpFDWE00"
Content-Disposition: inline
In-Reply-To: <35dd30c8-b31d-b8da-903a-0ea7eafb7e04@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org


--XWOWbaMNXpFDWE00
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 25, 2017 at 11:49:21PM -0700, John Hubbard wrote:
>>>
>>> Hi Wei,
>>>
>>> Is sections_per_block ever assigned a value? I am not seeing that happe=
n,
>>> either in this patch, or in the larger patchset.
>>>
>>=20
>> This is assigned in memory_dev_init(). Not in my patch.
>>=20
>
>ah, there it is, thanks. (I misread the diff slightly and thought you were=
 adding that
>variable, but I see it's actually been there forever.) =20
>

:-)

Welcome your comments.

>thanks
>john h
>

--=20
Wei Yang
Help you, Help me

--XWOWbaMNXpFDWE00
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZUZb0AAoJEKcLNpZP5cTdEFEP/2RCPo3M0rxASCygx50spoKZ
CQE4iC+Lzdk2YKNqKCNWXJdmYZ1gEU5QkUUm188mM428CxM8wxSnUMaWR6WgX1HT
w5bxvbvOpFDZqTl1zlw+BQrfmG2umJGfG7vqvdIGpOsjyMw/5UDajqHEX/L3arZj
EVT0mIzGEGBRrnzCoo8d+nIl+OJFl4qpjKxTVcLYYkfIdiIYkc1Zx+kRHHEvfQCS
J45s57VQmmB130S3wxSGf4Yo4T+aQgWK8oE/KccTeNYrsdi6L3vsVUde+0Ma9lbn
ykg2VlNwOpO4YF+HjOOQomgajWh+sfyD8eT1bz3awUeoi2Qe8uoHfxN4Pqg5X8Bx
S868cra9nlM2kvcfkJfWgozStiZEBYM4QSNYZz3pfJcUoVMa9s9At3LD31+O/6Jf
HdT5edRVdVzluNqLIjMD/H3GNZvrEufCN8abwp2aTNZxcvtqR75dS7zqseUfK56S
orJIBZn8eJsmskIX7qXpPg/wY6x3zZGeObuFW+43cPYDkijRHPdDxWa1K8GAfjEm
wnI9k1cGZS0opF4sW6gTi7gt6UIWF9JULn9T/hmvsEzjPsYutnjai8G2N1bfNbff
BjUowPaJ62Cw2CzdLFDFD2yLRa/I8X6qeHUp9/mm7UpbETopGSAxgk1uNFdxr8la
VKtSAjHv5KY8dKAYeXnA
=KE+t
-----END PGP SIGNATURE-----

--XWOWbaMNXpFDWE00--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
