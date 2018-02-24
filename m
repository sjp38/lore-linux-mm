Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 270EE6B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 08:48:40 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n14so2231326wmc.0
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 05:48:40 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id r5si3052578wmd.10.2018.02.24.05.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Feb 2018 05:48:38 -0800 (PST)
Date: Sat, 24 Feb 2018 14:48:31 +0100
From: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: Re: [PATCH 0/5] PPC32/ioremap: Use memblock API to check for RAM
Message-ID: <20180224134831.iulzv7iiz3tq7icr@latitude>
References: <20180222121516.23415-1-j.neuschaefer@gmx.net>
 <ca471c17-d2a7-e8e6-2d5a-a5a534e7e6d9@c-s.fr>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="px5zsypbfveej6ru"
Content-Disposition: inline
In-Reply-To: <ca471c17-d2a7-e8e6-2d5a-a5a534e7e6d9@c-s.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>
Cc: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>


--px5zsypbfveej6ru
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 23, 2018 at 09:01:17AM +0100, Christophe LEROY wrote:
>=20
>=20
> Le 22/02/2018 =C3=A0 13:15, Jonathan Neusch=C3=A4fer a =C3=A9crit=C2=A0:
> > This patchset solves the same problem as my previous one[1] but follows
> > a rather different approach. Instead of implementing DISCONTIGMEM for
> > PowerPC32, I simply switched the "is this RAM" check in __ioremap_caller
> > to the existing page_is_ram function, and unified page_is_ram to search
> > memblock.memory on PPC64 and PPC32.
> >=20
> > The intended result is, as before, that my Wii can allocate the MMIO
> > range of its GPIO controller, which was previously not possible, because
> > the reserved memory hack (__allow_ioremap_reserved) didn't affect the
> > API in kernel/resource.c.
> >=20
> > Thanks to Christophe Leroy for reviewing the previous patchset.
>=20
> I tested your new serie, it doesn't break my 8xx so it is OK for me.

Thanks for testing it!


Jonathan Neusch=C3=A4fer

--px5zsypbfveej6ru
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJakW0oAAoJEAgwRJqO81/bnNkP+wZw677bWbfnSz2yBIcXvWEF
rDZ1mxe7lkYQOB66/e07uuc/1MUFv2I01x8nF6hCGE1jRqE7P2UoTM8659xjpbGv
iSp+W1qc2KRjyrCXXUW/5gsCHW6Hs0uyDTsmfx9uHPmnVB0UedgFbseNTafL+Hna
0gwVM1mXRQSewlg/JV1jiEIonJvS4YOMM5TAFWT91FDZzsC7vLE/WsJrtAQaxfBY
IOe+0/PMICU9bBRk2wGkf8Aw89ydLPfwYKam6kABhsNFapBU61Rq6q4roOl0ZZp1
iPhzF45leSGjy1MU+f+jzZA4c58xJE82wJpxK5kES9v6yIOLGYjaMkmWVUj0FaOU
ky0TIc2mj4qRCIuMo8x0X0dMut1Je6Hri4JzlB01H1FgEvOoCj6exl4IIF69LU6A
mfJOZ9zPsaRrImqlT7i+sQwdTCC5733AdXssiotNuqLhSWpmfVv32EhjA6+ASNRk
jI5p24iIeneVCh7wV6XGeQXC3JR9ZLH8+H4OFCps2ElMjeHr35qtnX8HPkhT10gD
HLWSoZN5+itF5ZZn3KlowtUGHM7iycJz3VXbY6bYZp6+SmV0VL5K34b0NtmKQtUC
4M0Nu2X98Wluv37Zkh7Nc0mbodsS3RUDqMvcHPXuFZJN4sug/0BKqjtnq/V2p7sS
AHKoHGYHVDzl3QfavCBs
=RpIO
-----END PGP SIGNATURE-----

--px5zsypbfveej6ru--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
