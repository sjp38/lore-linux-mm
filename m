Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1A98D6B00DC
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 03:01:25 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fb1so2052718pad.17
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 00:01:24 -0700 (PDT)
Received: from psmtp.com ([74.125.245.122])
        by mx.google.com with SMTP id mi5si1032077pab.280.2013.10.24.00.01.23
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 00:01:24 -0700 (PDT)
Message-ID: <5268C5A9.5040303@ti.com>
Date: Thu, 24 Oct 2013 10:00:57 +0300
From: Tomi Valkeinen <tomi.valkeinen@ti.com>
MIME-Version: 1.0
Subject: Re: OMAPFB: CMA allocation failures
References: <1296360712.2526.1382565582863.JavaMail.apache@mail82.abv.bg>
In-Reply-To: <1296360712.2526.1382565582863.JavaMail.apache@mail82.abv.bg>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="6eVjXObUFnsccQ7tDqomOhpqqrvb5Mmm0"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?0JjQstCw0LnQu9C+INCU0LjQvNC40YLRgNC+0LI=?= <freemangordon@abv.bg>
Cc: sre@debian.org, tony@atomide.com, pali.rohar@gmail.com, pc+n900@asdf.org, pavel@ucw.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--6eVjXObUFnsccQ7tDqomOhpqqrvb5Mmm0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

On 24/10/13 00:59, =D0=98=D0=B2=D0=B0=D0=B9=D0=BB=D0=BE =D0=94=D0=B8=D0=BC=
=D0=B8=D1=82=D1=80=D0=BE=D0=B2 wrote:
>  Hi,
>=20
> I wonder if there is any progress on the issue? Do you need me to send =
more data? Or
> should I raise the issue with the CMA maintainer?

No, I haven't had time to look at this. And frankly, I don't even have
an idea what to look for if I can't reproduce it. The issue is not about
display, but DMA allocation, of which I know very little.

So yes, I suggest you try to discuss this with CMA/DMA people.

 Tomi

>=20
> Regards,
> Ivo
>=20
>  >-------- =D0=9E=D1=80=D0=B8=D0=B3=D0=B8=D0=BD=D0=B0=D0=BB=D0=BD=D0=BE=
 =D0=BF=D0=B8=D1=81=D0=BC=D0=BE --------
>  >=D0=9E=D1=82:  =D0=98=D0=B2=D0=B0=D0=B9=D0=BB=D0=BE =D0=94=D0=B8=D0=BC=
=D0=B8=D1=82=D1=80=D0=BE=D0=B2=20
>  >=D0=9E=D1=82=D0=BD=D0=BE=D1=81=D0=BD=D0=BE: Re: OMAPFB: CMA allocatio=
n failures
>  >=D0=94=D0=BE: Tomi Valkeinen=20
>  >=D0=98=D0=B7=D0=BF=D1=80=D0=B0=D1=82=D0=B5=D0=BD=D0=BE =D0=BD=D0=B0: =
=D0=A1=D1=80=D1=8F=D0=B4=D0=B0, 2013, =D0=9E=D0=BA=D1=82=D0=BE=D0=BC=D0=B2=
=D1=80=D0=B8 16 09:33:51 EEST
>  >
>  >
>  > Hi Tomi,
>  >
>  >>I think we should somehow find out what the pages are that cannot be=

>  >>migrated, and where they come from.
>  >>
>  >>So there are &amp;quot;anonymous pages without mapping&amp;quot; wit=
h page_count(page) !=3D
>  >>1. I have to say I don't know what that means =3D). I need to find s=
ome
>  >>time to study the mm.
>  >
>  >I put some more traces in the point of failure, the result:
>  >page_count(page) =3D=3D 2, page->flags =3D=3D 0x0008025D, which is:
>  >PG_locked, PG_referenced, PG_uptodate, PG_dirty, PG_active, PG_arch_1=
, PG_unevictable
>  >Whatever those mean :). I have no idea how to identify where those pa=
ges come from.
>  >
>  >>Well, as I said, you're the first one to report any errors, after th=
e
>  >>change being in use for a year. Maybe people just haven't used recen=
t
>  >>enough kernels, and the issue is only now starting to emerge, but I
>  >>wouldn't draw any conclusions yet.
>  >
>  >I am (almost) sure I am the first one to test video playback on OMAP3=
 with DSP video
>  >acceleration, using recent kernel and Maemo5 on n900 :). So there is =
high probability the
>  >issue was not reported earlier because noone have tested it thoroughl=
y after the change.
>  >
>  >>If the CMA would have big generic issues, I think we would've seen
>  >>issues earlier. So I'm guessing it's some driver or app in your setu=
p
>  >>that's causing the issues. Maybe the driver/app is broken, or maybe =
that
>  >>specific behavior is not handled well by CMA. In both case I think w=
e
>  >>need to identify what that driver/app is.
>  >
>  >What I know is going on, is that there is heavy fs I/O at the same ti=
me - there is
>  >a thumbnailer process running in background which tries to extract th=
umbnails of all video
>  >files in the system. Also, there are other processes doing various jo=
bs (e-mail fetching, IM
>  >accounts login, whatnot). And in addition Xorg mlocks parts of its ad=
dress space. Of course
>  >all this happens with lots of memory being swapped in and out. I gues=
s all this is related.
>  >
>  >However, even after the system has settled, the CMA failures continue=
 to happen. It looks like
>  >some pages are allocated from CMA which should not be.
>  >
>  >>I wonder how I could try to reproduce this with a generic omap3 boar=
d...
>  >
>  >I can always reproduce it here (well, not on generic board, but I gue=
ss it is even better to
>  >test in real-life conditions), so if you need some specific tests or =
traces or whatever, I
>  >can do them for you.
>  >
>  >Regards,
>  >Ivo
>  >
>=20



--6eVjXObUFnsccQ7tDqomOhpqqrvb5Mmm0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJSaMWuAAoJEPo9qoy8lh71y3sQAIowX40AHZYu+WbAssoo+4pQ
G3+ac5AS1gLwQsG90QeDF4ElmbmUuz/Tl3iA389lUcXpugrxKO0b2vqTFo043R4l
Q9u0Fiw4dmUZf6cNqAzZYkW0GNFPzWGPqVZgPgRTpxoS0sKrdwlSExbzTCp7zTlF
S2WqsIQU8IRRoJm8Z2oY9gxvTSM/VMTL7GY+Eu26UAe4hNoEXe818OvKupjTY19f
Hiom5sSpfN4lu0aRe7A6Py7WQ5hTofM81swa5LahGVMhQwkhWS2YhVe41fjdienK
K7oocAvoB0bMmvya/cEFiKL5jHw3ax69jrMzA5bljbkbZPAe4c5Ua1Wou/aVr8Hs
IBl1514lEFtgIyMgSVCW61upqsTVQOLoahF6lVdweWNYwwI+IN2kgllCNfgfnxAP
AUZTH+heYAjprwJM3nRw0FuCujj9ZXgGXFccqzMSh+EL8mgXiKoU7DzgknS1BrjZ
Tfw5MQYeU08VyCcfHDJqo95hUVtDEnI7UKyu6NpGrGqAJ53nJ3gPzBbYPethOHBz
oDa4SaaxrgnAPN49RUtI3nDiihcly0uYWbiqR2qsyuFmhvuPH35Z7LNI1+Ln27xo
52o9a2NjLz+etG7E7s9L/eS4YDIXiimRPxc6EFV4hsrNl1lWxLdKvmmUD1M+bIH+
hjPaKcCGaBTaDiQbon6p
=WfQ8
-----END PGP SIGNATURE-----

--6eVjXObUFnsccQ7tDqomOhpqqrvb5Mmm0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
