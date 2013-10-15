Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 48EAD6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 03:37:11 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so8573227pab.25
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 00:37:10 -0700 (PDT)
Message-ID: <525CF09A.1080808@ti.com>
Date: Tue, 15 Oct 2013 10:36:58 +0300
From: Tomi Valkeinen <tomi.valkeinen@ti.com>
MIME-Version: 1.0
Subject: Re: OMAPFB: CMA allocation failures
References: <991366690.30380.1381819791799.JavaMail.apache@mail83.abv.bg>
In-Reply-To: <991366690.30380.1381819791799.JavaMail.apache@mail83.abv.bg>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="2NnVkUO1Sil0BTIjhbJwuawxSTiMJGaw6"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?0JjQstCw0LnQu9C+INCU0LjQvNC40YLRgNC+0LI=?= <freemangordon@abv.bg>
Cc: pali.rohar@gmail.com, pc+n900@asdf.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--2NnVkUO1Sil0BTIjhbJwuawxSTiMJGaw6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 15/10/13 09:49, =D0=98=D0=B2=D0=B0=D0=B9=D0=BB=D0=BE =D0=94=D0=B8=D0=BC=
=D0=B8=D1=82=D1=80=D0=BE=D0=B2 wrote:

> I am using my n900 as a daily/only device since the beginning of 2010, =
never seen such an=20
> issue with video playback. And as a maintainer of one of the community =
supported kernels for
> n900 (kernel-power) I've never had such an issue reported. On stock ker=
nel and derivatives of
> course. It seems VRAM allocator is virtually impossible to fail, while =
with CMA OMAPFB fails on
> the first video after boot-up.

Yes, I think with normal fb use it's quite difficult to fragment VRAM
allocator too much.

> When saying you've not seen such an issue - did you actually test video=
 playback, on what
> device and using which distro? Did you use DSP accelerated decoding?

No, I don't have a rootfs with DSP, and quite rarely test video
playback. But the VRAM allocator was removed a year ago, and this is the
first time I've seen anyone have issues with the CMA.

> I was able to track down the failures to:
> http://lxr.free-electrons.com/source/mm/migrate.c#L320
>=20
> So it seems the problem is not that CMA gets fragmented, rather some pa=
ges cannot be migrated.
> Unfortunately, my knowledge stops here. Someone from the mm guys should=
 be involved in the
> issue as well? I am starting to think there is some serious issue with =
CMA and/or mm I am
> hitting on n900. As it is not the lack of free RAM that is the problem =
-=20
> "echo 3>/proc/sys/vm/drop_caches" results in more that 45MB of free RAM=
 according to free.

I think we should somehow find out what the pages are that cannot be
migrated, and where they come from.

So there are "anonymous pages without mapping" with page_count(page) !=3D=

1. I have to say I don't know what that means =3D). I need to find some
time to study the mm.

> dma_declare_contiguous() won't help IMO, it just reserves CMA area that=
 is private to the
> driver, so it is used instead of the global CMA area, but I don't see h=
ow that would help in my
> case.

If the issue is not about fragmentation, then I think you're right,
dma_declare_contiguous won't help.

> Anyway, what about reverting VRAM allocator removal and migrating it to=
 DMA API, the same way
> DMA coherent pool is allocated and managed? Or simply revering VRAM all=
ocator removal :) ?

Well, as I said, you're the first one to report any errors, after the
change being in use for a year. Maybe people just haven't used recent
enough kernels, and the issue is only now starting to emerge, but I
wouldn't draw any conclusions yet.

If the CMA would have big generic issues, I think we would've seen
issues earlier. So I'm guessing it's some driver or app in your setup
that's causing the issues. Maybe the driver/app is broken, or maybe that
specific behavior is not handled well by CMA. In both case I think we
need to identify what that driver/app is.

I wonder how I could try to reproduce this with a generic omap3 board...

 Tomi



--2NnVkUO1Sil0BTIjhbJwuawxSTiMJGaw6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJSXPCaAAoJEPo9qoy8lh71k9QQAJMn2tGIaZ7bXMn//i+ZQDNK
keJCykU+3mTt6QD4oqFPs1tda0sLTnXx6de2Tn1fGV7XbIqARfpkdC4W1/Y07IdE
HVDDQ+RhGc0tSyBsWI0qlx8DwCb4N+qeHZxuvjUlpDOZyDl9ppfzkfTfyQVraDmi
+7fhJQeJD0bbaji2vAtu5yxzrqDRE1UDyDh6wWocrKN1nGXspjNs+zmk/MFwQhYL
GEILOqgVJYKerQDUTeqQRN6blOZCjrs4yhTFMZD0W9WCcVE5qJ/ipQ3Nd3pCQStq
hOUQnqWQGoNfjIG9enpnsVXI9au7bu2nB9fWOzbpkGx1yzM7xVz6caKoLAMtlhkU
soFgAXxG5+jffz6H6iGLv7dMl/BDqkT9Ag5JDxlKC59MD5SM6+gcl+ONOQokljI9
LSJbtJWd+KVtIvU10LYtABUtsjUlZWbsBYtj+BvILFvRQ3b2Q+vGmVy1m3WvROHm
Xh7mFMPqtHthA6lpbIB7/lFS9zmOP6ajNU4j08dv0C7rCmi739cAzj8vDXF+ljW4
GH7orEmsN1SitF0HpCCjg/WisKbIl3cDqlptA+2qNvRoTQ4IXakvstE2B58nU0lJ
gmSA9rH4tz5tS/ONFewcPvfbNedGZ1uwt4Y1h9U1kr6Aqfvz+EsKqyqwbqI+CRrh
7ZNdYC5WDC/jJRKmI5yK
=4Lq8
-----END PGP SIGNATURE-----

--2NnVkUO1Sil0BTIjhbJwuawxSTiMJGaw6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
