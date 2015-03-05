Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7E22E6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 18:41:22 -0500 (EST)
Received: by padbj1 with SMTP id bj1so12983470pad.12
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 15:41:22 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id lr6si11767126pab.66.2015.03.05.15.41.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 15:41:21 -0800 (PST)
Date: Fri, 6 Mar 2015 10:41:13 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] Fix undefined ioremap_huge_init when CONFIG_MMU is not
 set
Message-ID: <20150306104113.555c8888@canb.auug.org.au>
In-Reply-To: <1425570246-812-1-git-send-email-toshi.kani@hp.com>
References: <1425570246-812-1-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/EIzWkTjUQe/.6RN7YfL/5SA"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, kbuild-all@01.org, fengguang.wu@intel.com, hannes@cmpxchg.org

--Sig_/EIzWkTjUQe/.6RN7YfL/5SA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Toshi,

On Thu,  5 Mar 2015 08:44:06 -0700 Toshi Kani <toshi.kani@hp.com> wrote:
>
> Fix a build error, undefined reference to ioremap_huge_init, when
> CONFIG_MMU is not defined on linux-next and -mm tree.
>=20
> lib/ioremap.o is not linked to the kernel when CONFIG_MMU is not
> defined.
>=20
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  include/linux/io.h |    5 +++--
>  lib/ioremap.c      |    1 -
>  2 files changed, 3 insertions(+), 3 deletions(-)

Added to my copy of the akpm-current tree today (and so into linux-next).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/EIzWkTjUQe/.6RN7YfL/5SA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU+OmdAAoJEMDTa8Ir7ZwVW34P/1KSbNFXvcpU7ITotjEPswOQ
KJQ2CWqMVlemNiC++UqiiyrRHHQdy5TmzqEpftTRw+kJXVuqyFdq9DFrCBIqLP3p
bdcB2F6+D962fDI8UlZNOME8JYrsUNkTtdN5hQCoLk4D/YwDDJZqKjMv9qIt2r4h
/92aBpXpMjRZYEX6wYQDE8pux2y5ckeFrGY0VvamDYCqvX8M9G2XlO5bOzl6NPFa
Jzol5TxwTf52drNuxxTPmLS7GQB4gIlHtzy8CK4Pfuc8jxjaylWL7N8fOafb/Is3
Rcktz4MmC2FkfkFgJ594a3gNoqXGTZn20Sb8t+6Z60sIh36TGJXwwAxvsZSzfYaF
cuV2GqvMCD5SPbVmW0ORcxEzz71GVEcEVKNzsZHGcVC0SJ/07qfNt+xR6YyV01E0
IExWTHi5dpEr2uPPxPlyXk3p7t/0Cn6heTG5w/QP+0GCYJwCVlQAsqxHanMypwJ3
4oslW6xhwlau3w5p9KiESHVKRuoWJvdqfP0Uvcj55xOqr8tyhF+/4z1bXWR6xWat
aR931R++pa1z8HvQf0sxSxapE2h7nvaPk7dPQBzK1XEyYkvaPfSHOq8xbeTswhjp
p7VjJPOYPJuVDRwCEFJEIqbkONgWx2gAI10LU66yZSXLTeSd/AH+W5eVjhwnyPKU
Wdum/qSryvPfH7fG8HbP
=VFNl
-----END PGP SIGNATURE-----

--Sig_/EIzWkTjUQe/.6RN7YfL/5SA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
