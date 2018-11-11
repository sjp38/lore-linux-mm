Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 055316B0008
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 20:38:46 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id b204-v6so5517632wme.6
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 17:38:45 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id x11-v6si9763526wrp.16.2018.11.10.17.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Nov 2018 17:38:44 -0800 (PST)
Message-ID: <6f5448ebd339cd1dc7ffa8fdbe3a2fd813593260.camel@decadent.org.uk>
Subject: Re: [linux-stable-rc:linux-3.16.y 2872/3488] head64.c:undefined
 reference to `__gcov_exit'
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 11 Nov 2018 01:38:29 +0000
In-Reply-To: <CAK8P3a1E4=NJaZKM0z8b62ahSoBjR1K2oLsHhbY9C03Kkeeu8g@mail.gmail.com>
References: <201802170216.gfRZgPtX%fengguang.wu@intel.com>
	 <CAK8P3a1E4=NJaZKM0z8b62ahSoBjR1K2oLsHhbY9C03Kkeeu8g@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/vmpg2gsZH75s4vuTeSi"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, kbuild test robot <fengguang.wu@intel.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, kbuild-all@01.org, Ben Hutchings <bwh@kernel.org>, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable <stable@vger.kernel.org>


--=-/vmpg2gsZH75s4vuTeSi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2018-02-16 at 21:28 +0100, Arnd Bergmann wrote:
> On Fri, Feb 16, 2018 at 7:21 PM, kbuild test robot
> <fengguang.wu@intel.com> wrote:
[...]
> > All errors (new ones prefixed by >>):
> >=20
> >    arch/x86/kernel/head64.o: In function `_GLOBAL__sub_D_00100_1_early_=
pmd_flags':
> > > > head64.c:(.text.exit+0x5): undefined reference to `__gcov_exit'
> >    arch/x86/kernel/head.o: In function `_GLOBAL__sub_D_00100_1_reserve_=
ebda_region':
> >    head.c:(.text.exit+0x5): undefined reference to `__gcov_exit'
> >    init/built-in.o: In function `_GLOBAL__sub_D_00100_1___ksymtab_syste=
m_state':
> >    main.c:(.text.exit+0x5): undefined reference to `__gcov_exit'
> >    init/built-in.o: In function `_GLOBAL__sub_D_00100_1_root_mountflags=
':
> >    do_mounts.c:(.text.exit+0x10): undefined reference to `__gcov_exit'
> >    init/built-in.o: In function `_GLOBAL__sub_D_00100_1_initrd_load':
> >    do_mounts_initrd.c:(.text.exit+0x1b): undefined reference to `__gcov=
_exit'
> >    init/built-in.o:initramfs.c:(.text.exit+0x26): more undefined refere=
nces to `__gcov_exit' follow
>=20
> I think this is a result of using a too new compiler with the old 3.16
> kernel. In order
> to build with gcc-7.3, you need to backport
>=20
> 05384213436a ("gcov: support GCC 7.1")
>=20
> It's already part of stable-3.18 and later, but not 3.2 and 3.16.

Thanks.  I've queued up the following for 3.16:

3e44c471a2da gcov: add support for GCC 5.1
d02038f97253 gcov: add support for gcc version >=3D 6
05384213436a gcov: support GCC 7.1

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.



--=-/vmpg2gsZH75s4vuTeSi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlvniBUACgkQ57/I7JWG
EQmu0A//barvpTwZjirJl9xlswHWSd+py5x/ajnJUWfpeDu3eFatjwqamXdE3aBu
x8nt2xzyqru0Fpn8x8Hhv7S3tY5HuKKfJ6rkj8SCdiW06jJMICoJI6zPobS1od0y
oJQ0P5xLCy0Ms67W40gCb6adVc6MnANqMeHdSdbakL/y1y/l9FvBlo2d6/QetKVP
x1dOCql4zkUnRWyqCFAsogUAvp1P/XRIJSfGi5cfge3bzsC2wRUzWNrUq7V4bfds
ZmUtPNUqwvOZiJyDGqQyHkvBGwP/Fk0Zy9q0FA3kvG8b0iIVnJD/WR7PLR9hHX9B
dC1P2fYft/Gvr7M6gdxIaMb2dNrwZZ3yJ7xc0O2Fb6VocV9V7GM1Ins5adcftHGD
1VGdAWpmIAdmX/rrrBHY62+LmPPy8dQcH/xVyjkwEqL8+vMcO2oBiSlSKAMI8E4A
10XF3yZJ8dvsUyJ6gG+4aqA+gsTgB3zkLSZGuVh7HPzanDAt7VcPYwkbalQLK+y4
wbMEt9r8RZ2LWZgmnEW2ZmPXx0qL7DGbRaZinteobe+XCtcANcq1+/DNdTzCEoTJ
fkE0yZ8BJNiEJepCmLuBh3d9m8r6e0vw+nWjjm7RY+607r4InEMIRmIA9wc8P7Ex
YM8c5ZUwie6LuPQqdf1ApPMv2LjI3jt07v8Mt/DR5IOlp+nSIqU=
=N+5O
-----END PGP SIGNATURE-----

--=-/vmpg2gsZH75s4vuTeSi--
