Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 318F16B0037
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 18:31:12 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ma3so1244711pbc.13
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:31:11 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id bi5si1388770pbb.492.2014.04.23.15.31.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 15:31:10 -0700 (PDT)
Date: Thu, 24 Apr 2014 08:31:00 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2014-04-22-15-20 uploaded (uml 32- and 64-bit defconfigs)
Message-Id: <20140424083100.c5f32e14abd2f6ed05673cb9@canb.auug.org.au>
In-Reply-To: <20140423151819.d752391e323a850ca0aded57@linux-foundation.org>
References: <20140422222121.2FAB45A431E@corp2gmr1-2.hot.corp.google.com>
	<5357F405.20205@infradead.org>
	<20140423134131.778f0d0a@redhat.com>
	<5357FCEB.2060507@infradead.org>
	<20140423141600.4a303d95@redhat.com>
	<20140423112442.5a5c8f23d580a65575e0c5fc@linux-foundation.org>
	<20140424081019.596b5d23c624f5721ba0480a@canb.auug.org.au>
	<20140423151819.d752391e323a850ca0aded57@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__24_Apr_2014_08_31_00_+1000_0Dhfh/.RqrYqxFm6"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, nacc@linux.vnet.ibm.com, Richard Weinberger <richard@nod.at>

--Signature=_Thu__24_Apr_2014_08_31_00_+1000_0Dhfh/.RqrYqxFm6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, 23 Apr 2014 15:18:19 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> Stephen who?
>=20
> Oh, that guy who sends stuff first then comes last when others use LIFO :)

Ah ha!  So all I have to do is stamp my emails a day ahead?  Or queue
them up and send them via a cron job just after "Andrew's breakfast
time"? :-)

Anyway, I was more suggesting that Randy and the others could have saved
themselves time by reading that email.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__24_Apr_2014_08_31_00_+1000_0Dhfh/.RqrYqxFm6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTWD8pAAoJEMDTa8Ir7ZwV2qkP/i56IWTfQzb5LesqyA27W2Vf
ZXsUjBURwZeAAIO5phkqqAEf8xiGquOq7MGif87oCTrDqwYxnF5FrRHrcu75tufZ
BmfqRv4cEqLhCw8y0a2J6Hi2vTIdOrfTjGGLyHXvmppJ6CgvRg/3tMWtJJb5zdbw
v8eI4svOQT+xpZl6pURtSMLcHsm4OP/NYbPzeg5SzMbtkRy7f4OSTvVFMHjCFvXM
zwr4ulNEkYD8xeOXUzzF46Cw6wITShV5BsdyWhteldq8vuwRxlUL/Eitqk6yciQT
WOqYRgsKzoGbut9ykT24TytJRI0/iUYCUpd8new5PHHJebnZSL/rFJ/cvUjSC3iD
IUgUgONsj+TIXUbUZEi3Rk+OwZS1b+dw3prbKYS+SlwnBDmOgN2X1L6ImkZOixTN
B6nIgjg69Cr6QvivLoyw5agpFFPCtWjQsgFzCjNqvPgkf/EiiIGpuXLzySOVJQRC
E9LVkYOONFMwZKLy0T2g6bYH14YFx8/xv3X9oP2zolEFZNGuPkYrb7G/IhOU9U9C
kOfmr7IpX3Yw/RyHa76hlBXzan+MSB8hp+Ik57azo5Hl5mHF8YpBIqYDBY/XsMr9
P1FARil3gnMg4PCLXJ+vi27B27muBoUh8GcV0Mpri9bF0PGlQ6ZFK3fzMqSxl87v
pKHXngzzYjBnd0Dzd5vH
=lZl8
-----END PGP SIGNATURE-----

--Signature=_Thu__24_Apr_2014_08_31_00_+1000_0Dhfh/.RqrYqxFm6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
