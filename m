Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id E43B96B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 08:19:55 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so1296094pbc.23
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 05:19:55 -0700 (PDT)
Received: from psmtp.com ([74.125.245.116])
        by mx.google.com with SMTP id sd2si2534825pbb.79.2013.10.30.05.19.54
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 05:19:54 -0700 (PDT)
Message-ID: <5270F954.7090109@ti.com>
Date: Wed, 30 Oct 2013 14:19:32 +0200
From: Tomi Valkeinen <tomi.valkeinen@ti.com>
MIME-Version: 1.0
Subject: Re: OMAPFB: CMA allocation failures
References: <737255712.30460.1383050855911.JavaMail.apache@mail83.abv.bg>
In-Reply-To: <737255712.30460.1383050855911.JavaMail.apache@mail83.abv.bg>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="W9s40lN3eLvF4JkxdkiFiqr1NkHNPgHUX"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?0JjQstCw0LnQu9C+INCU0LjQvNC40YLRgNC+0LI=?= <freemangordon@abv.bg>
Cc: Minchan Kim <minchan@kernel.org>, pavel@ucw.cz, sre@debian.org, pali.rohar@gmail.com, pc+n900@asdf.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--W9s40lN3eLvF4JkxdkiFiqr1NkHNPgHUX
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 2013-10-29 14:47, =D0=98=D0=B2=D0=B0=D0=B9=D0=BB=D0=BE =D0=94=D0=B8=D0=
=BC=D0=B8=D1=82=D1=80=D0=BE=D0=B2 wrote:

> However, back to omapfb - my understanding is that the way it uses CMA =
(in its current form) is
> prone to allocation failures way beyond acceptable.=20
>=20
> Tomi, what do you think about adding module parameters to allow pre-all=
ocating framebuffer memory
> from CMA during boot? Or re-implement VRAM allocator to use CMA? As a g=
ood side-effect=20
> OMAPFB_GET_VRAM_INFO will no longer return fake values.

I really dislike the idea of adding the omap vram allocator back. Then
again, if the CMA doesn't work, something has to be done.

Pre-allocating is possible, but that won't work if there's any need to
re-allocating the framebuffers. Except if the omapfb would retain and
manage the pre-allocated buffers, but that would just be more or less
the old vram allocator again.

So, as I see it, the best option would be to have the standard dma_alloc
functions get the memory for omapfb from a private pool, which is not
used for anything else.

I wonder if that's possible already? It sounds quite trivial to me.

 Tomi



--W9s40lN3eLvF4JkxdkiFiqr1NkHNPgHUX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJScPlUAAoJEPo9qoy8lh711TsP/2SfzniMK0u34V6vrRvOFECE
9zd9dy/3+0HEzSVLcb22GfLPZf6ygPqSTR7951Gfd8V3Fh7KSNOiIGGRBzbxVvzy
glc8IqWY4C4d4CCxVGEaPPzLznUw86FNnNUYwS1BfjGIKlrfDlqFVFAB2IT9+fe0
qDN4VEReNLZwrOKgG9Qco30zKnRWFTgCgwLqXctVVoymHHkbgbV6YsPu/piuKAMJ
5PTGOBlxqiEyDBBwTlU1YYKzhN/pLbkUFQQfhgGmd2fEHHEbQAQvgY3ftUcn8C7a
2UNALMCheZ53ejqF75wZkcOUFfmRLI+CsFeVhlhIMaLy77LgEynHEwvGchFnsCaK
CaiEaBA+oAh/OTWKwc6giGkARmaedl4wU95YHAYFMzzGUY06+MrdGiRY6QS3fQ0q
wBx6gUQPgw2ToTXJp6CiwoMGRZ5fvX7ox+uLY+pF41C0wwGqVxfHSU4A9m2dbs42
KjbyCoL3CFkEBO8X1/Jmfyf7+gXvEU32gfqVSvRuP2mkpGpUQJSzRFEPcaJaNuT/
Jzbuza80Tnf6t/BITKUT4dqTQVSgEcKk/XoGyz1C8owGIfk0mHjNiAkZwmBoyu9+
IA7T0U9Pu2Og6MFVN6x22xe8Y+OhT9Fscr0UZ+gTbPQYMu0adDBDmA0AyZmp3d29
KqqiTERbI4Kqna5EHEIZ
=3YNa
-----END PGP SIGNATURE-----

--W9s40lN3eLvF4JkxdkiFiqr1NkHNPgHUX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
