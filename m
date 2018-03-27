Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D207F6B0012
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 15:24:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z83so168042wmc.2
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 12:24:18 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.20])
        by mx.google.com with ESMTPS id d37si1509796wma.151.2018.03.27.12.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 12:24:17 -0700 (PDT)
Date: Tue, 27 Mar 2018 21:24:10 +0200
From: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: Re: [PATCH 3/5] powerpc/mm/32: Use page_is_ram to check for RAM
Message-ID: <20180327192410.nvu6s4ekctuuybnn@latitude>
References: <20180222121516.23415-1-j.neuschaefer@gmx.net>
 <20180222121516.23415-4-j.neuschaefer@gmx.net>
 <874llcha6p.fsf@concordia.ellerman.id.au>
 <87y3iofh2z.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="odiormwvl2eyppks"
Content-Disposition: inline
In-Reply-To: <87y3iofh2z.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Joel Stanley <joel@jms.id.au>, Guenter Roeck <linux@roeck-us.net>


--odiormwvl2eyppks
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Mar 19, 2018 at 10:19:32PM +1100, Michael Ellerman wrote:
> Michael Ellerman <mpe@ellerman.id.au> writes:
> > Jonathan Neusch=C3=A4fer <j.neuschaefer@gmx.net> writes:
[...]
> >> -	if (slab_is_available() && (p < virt_to_phys(high_memory)) &&
> >> +	if (page_is_ram(__phys_to_pfn(p)) &&
> >>  	    !(__allow_ioremap_reserved && memblock_is_region_reserved(p, siz=
e))) {
> >>  		printk("__ioremap(): phys addr 0x%llx is RAM lr %ps\n",
> >>  		       (unsigned long long)p, __builtin_return_address(0));
> >
> >
> > This is killing my p5020ds (Freescale e5500) unfortunately:
>=20
> Duh, I should actually read the patch :)
>=20
> This is a 32-bit system with 4G of RAM, so not all of RAM is mapped,
> some of it is highem which is why removing the test against high_memory
> above breaks it.
>=20
> So I need the high_memory test on this system.

This is an oversight on my part. I thought I wouldn't need this test
because the memblock-based test is more accurate, but I didn't think
through how high memory actually works.

> I'm not clear why it was a problem for you on the Wii, do you even build
> the Wii kernel with HIGHMEM enabled?

No. The Wii works fine with the p < virt_to_phys(high_memory) test, and
doesn't use CONFIG_HIGHMEM.  I'll send a version two of this patchset.


Thanks for testing,
Jonathan Neusch=C3=A4fer

--odiormwvl2eyppks
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJauppRAAoJEAgwRJqO81/b5NYP/jkaQNZCNCajFmaHnqWkrQvb
AxOfaAW6X8ovEeTBfDzuw95k9IggHnK8I5q0+BBiAaW+Sr3DSfvVAU7s7yskIyw9
+VoblsmJblgCRbE7O5Z+gn7eDJwEtZsssBbq1jo2SVfoo+h/mKyt+sHfdNFGHf80
nZy4O66uL43VHqc7F5ZLXfPe2hhjepnfCMu3vZhaIM7jeAKxL1yUyvD8j/iKVFm7
7MnyksFbUemVpM+R/Vs52Cn8Pg1bipNX2cqqc7ewEdl0cELz+TU+k66Rd7JXVTCt
9o9xTSIC67BSks6JvwTuHX3Z76cWFY85vKZ7WKlt+Z1idIdZZH2kVEZ+C0efegit
DXX0hcxWJKx2XUp4O0NeFk9IDF6bJ0LwQ7J7waf1TGeASFobgABx+hUK7mvtfifg
OmrN2/59KVswGWxA7vkIx/HK8aWlA2YPposb99LIlHS7N4aQjCTHaSm9nyO+vQvN
ROJQ3vthGSWeE+v83CXgtLLpu5sLN10IZNCavlVLNhiMRg4GkkfsMu34J7l+bEn3
dvYAuY9fppNe7B/+0zNeaoZpJAko3zly851wqHx//l+glUbBOPTyCOJmc3LC9Git
INjN1o0BHOK9AB717V/bP+5R9la7AaYxM012vs9VfB+Aa2UUsgyHweHb/4TDK0c2
ewozCrRV9FEJ4WXWzIcB
=e+pw
-----END PGP SIGNATURE-----

--odiormwvl2eyppks--
