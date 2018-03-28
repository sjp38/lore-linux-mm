Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD83B6B0027
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 11:21:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v25so1424738pgn.20
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 08:21:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g7-v6si4184199plm.539.2018.03.28.08.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 08:21:21 -0700 (PDT)
Date: Wed, 28 Mar 2018 16:21:15 +0100
From: James Hogan <jhogan@kernel.org>
Subject: Re: [PATCH V4 Resend] ZBOOT: fix stack protector in compressed boot
 phase
Message-ID: <20180328152115.GB1991@saruman>
References: <1522226933-29317-1-git-send-email-chenhc@lemote.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="oC1+HKm2/end4ao3"
Content-Disposition: inline
In-Reply-To: <1522226933-29317-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huacai Chen <chenhc@lemote.com>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, linux-sh@vger.kernel.org, stable@vger.kernel.org


--oC1+HKm2/end4ao3
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 28, 2018 at 04:48:53PM +0800, Huacai Chen wrote:
> diff --git a/arch/mips/boot/compressed/decompress.c b/arch/mips/boot/comp=
ressed/decompress.c
> index fdf99e9..81df904 100644
> --- a/arch/mips/boot/compressed/decompress.c
> +++ b/arch/mips/boot/compressed/decompress.c
> @@ -76,12 +76,7 @@ void error(char *x)
>  #include "../../../../lib/decompress_unxz.c"
>  #endif
> =20
> -unsigned long __stack_chk_guard;
> -
> -void __stack_chk_guard_setup(void)
> -{
> -	__stack_chk_guard =3D 0x000a0dff;
> -}
> +const unsigned long __stack_chk_guard =3D 0x000a0dff;
> =20
>  void __stack_chk_fail(void)
>  {
> @@ -92,8 +87,6 @@ void decompress_kernel(unsigned long boot_heap_start)
>  {
>  	unsigned long zimage_start, zimage_size;
> =20
> -	__stack_chk_guard_setup();
> -
>  	zimage_start =3D (unsigned long)(&__image_begin);
>  	zimage_size =3D (unsigned long)(&__image_end) -
>  	    (unsigned long)(&__image_begin);

This looks good to me, though I've Cc'd Kees as apparently the original
author from commit 8779657d29c0 ("stackprotector: Introduce
CONFIG_CC_STACKPROTECTOR_STRONG") in case there was a particular reason
this wasn't done in the first place.

Acked-by: James Hogan <jhogan@kernel.org>

(Happy to apply with acks from Kees and ARM, SH maintainers if nobody
else does).

Cheers
James

--oC1+HKm2/end4ao3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEd80NauSabkiESfLYbAtpk944dnoFAlq7suoACgkQbAtpk944
dnrxJxAAlrAgDS3oDkev9n/dI09IAb5AGksi/hRV8rvWiOecvAyIYE7RG0rthOmS
0loNyQOkdrydZy5n4BUO+OxjV8UJQnGazAeDPM5/gOqHZiuouSPg8JvfspH9dbCP
MJ09R/ig3biJiSNRYlW8L+cD6Zo4Iy/aEfusc0i+cRAC2kHJDJe6D0XoXHYSk2mj
Vx9jj9GoLTROXwtMhYRjsFb1qTfKL5NBY+66zMPV2pVnsQoV8PSMftdYz1RCU/VC
iNVFI5/pus+YVNL2nTqhUXRQUNDvOGqMt08yk4P1gyMLPHzEUf3uKHn12pMYslI2
H+LGmfe8MdwVG+Mb554Y1di245/kGybclsAdqMUK1RtbzrfuDOYv6u8GAop/d6cg
gjgnHstbImtbIyTGcT4aY4ntY/HftPJ/s7kTbIdFZGV0Pkzi4aCOiJSVqO/lLX0h
FzM5sFf/YcGyDMw8zCDlL9OfRWImuzIn89xvwdsEtorZvtgI9syxPZSLU8fNNwAy
jmPMm6PC1l5i+BwfO0UJO2M0HtIO/L9P3a67xdjrWZbMAFfp3X6PEGs1fu5c3QV1
MJ6SF316yu1pOnIbqLImqsY4/DYnHkhT3/evZAA5n4/Rxz3ICp+8OKYEbGmmbXV+
Bv7VIDn2vv+MlmIVDYELo1v+LWmX833VssiwXcHPlSS7s4XjT4w=
=au7i
-----END PGP SIGNATURE-----

--oC1+HKm2/end4ao3--
