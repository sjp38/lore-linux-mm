Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D716B6B025F
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 02:50:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r6so8894059pfj.14
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 23:50:01 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b3si237643plr.706.2017.10.19.23.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 23:50:00 -0700 (PDT)
Date: Fri, 20 Oct 2017 14:43:06 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: swapper/0: page allocation failure: order:0,
 mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
Message-ID: <20171020064305.GA13688@intel.com>
References: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
 <20171019035641.GB23773@intel.com>
 <CABXGCsPL0pUHo_M-KxB3mabfdGMSHPC0uchLBBt0JCzF2BYBww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xHFwDpU9dbj6ez1V"
Content-Disposition: inline
In-Reply-To: <CABXGCsPL0pUHo_M-KxB3mabfdGMSHPC0uchLBBt0JCzF2BYBww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Cc: "Du, Changbin" <changbin.du@intel.com>, linux-mm@kvack.org


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 19, 2017 at 11:52:49PM +0500, =D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=
=BB =D0=93=D0=B0=D0=B2=D1=80=D0=B8=D0=BB=D0=BE=D0=B2 wrote:
> On 19 October 2017 at 08:56, Du, Changbin <changbin.du@intel.com> wrote:
> > On Thu, Oct 19, 2017 at 01:16:48AM +0500, =D0=9C=D0=B8=D1=85=D0=B0=D0=
=B8=D0=BB =D0=93=D0=B0=D0=B2=D1=80=D0=B8=D0=BB=D0=BE=D0=B2 wrote:
> > I am curious about this, how can slub try to alloc compound page but th=
e order
> > is 0? This is wrong.
>=20
> Nobody seems to know how this could happen. Can any logs shed light on th=
is?
>
After checking the code, kernel can handle such case. So please ignore my l=
ast
comment.

The warning is reporting OOM, first you need confirm if you have enough free
memory? If that is true, then it is not a programmer error.

> --
> Best Regards,
> Mike Gavrilov.

--=20
Thanks,
Changbin Du

--xHFwDpU9dbj6ez1V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZ6Zr5AAoJEAanuZwLnPNUrj4H/3hHDXYAT9dmv0bCbqhe0b/f
WkVt/RcUfQHH3Qe6Ciggl7FfmR2cOJFzLn8rsJqGQ/tdva3gKkgI+jno4N00nuEa
TZf2wlrhI4vvKfPEaYXd1u0oXa/7NhUnuLzpK6x2TNzebuMU5QlhY/gTFXvxzVYI
/dQvwIGS2mUT0hptzzPYKovx9SX0OZr0H1OnDFWcl2+NH5oq99OWjnTQG4EJUaXd
0YHQTnfQjR3ZfRPSR/E6nBvA9svBu75KkfM4FIHi/f46/UJgbIZHDkGBGLkNugMW
6Er5PPjhcIKYU4tp6p33YbEFjnX0OzFLf6LjYNDl1j9rWtNzM6AnYt+iZQ32c/I=
=XQHO
-----END PGP SIGNATURE-----

--xHFwDpU9dbj6ez1V--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
