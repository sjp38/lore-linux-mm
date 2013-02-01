Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 28BD96B0028
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 21:57:30 -0500 (EST)
Message-ID: <1359687434.31386.53.camel@deadeye.wl.decadent.org.uk>
Subject: Re: Bug#695182: [RFC] Reproducible OOM with just a few sleeps
From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 01 Feb 2013 02:57:14 +0000
In-Reply-To: <201302010212.r112C6UQ005134@como.maths.usyd.edu.au>
References: <201302010212.r112C6UQ005134@como.maths.usyd.edu.au>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZEwXyXCb20IX49watm2+"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: 695182@bugs.debian.org, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@ucw.cz


--=-ZEwXyXCb20IX49watm2+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-02-01 at 13:12 +1100, paul.szabo@sydney.edu.au wrote:
> Dear Ben,
>=20
> >> PAE is broken for any amount of RAM.
> >
> > No it isn't.
>=20
> Could I please ask you to expand on that?

I already did, a few messages back.

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-ZEwXyXCb20IX49watm2+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUQsvCue/yOyVhhEJAQpY9xAA08DsjOdfHz1Ho5Ym3ZlqZWBQmBficolW
h0Z4XDj5YN8tQ4DPdgAGzjXwi3mVzl2GC3GcyVirYpBxbrOVx1u0dX787e25jLyq
tjZe7iGlds8/Klqmg3iqK2M0TJbm/3oH3C5gBsY9mBI+lwYdi7Fuh+rQivHNfy6N
M1tniykaFL2UiiccRBop2HKJg67SEXe38fxtLe9ZYNljGsY83tOugipALVW56ane
HQjNjRjv62iZMAatEppLa9gc719dUAE2CivrCPOILx91C+ToraOLVWREB9zwwTpY
7K0Nor73Q8ITbgwX0fdPE5Cm5zFeJEfgokn5vB8PTYvlI3/E6BX8erkS0whAxSo6
h/7hG6PrzJ6XcGTxCtjbn5qWHeUXwjDU6v28ipRDBlifMkJJ2HVXncoBKBJr4dHR
uHmppAWMZIAkTOum0XJx5LfAGwkHzZX0BnTNfh8ygop17ffybnelC64JqCBgabU/
29lbndNR9Pp4g/Mmr6jxGrsHgyZg1ADJbrudq/M7cWd7abihx/Gy46CO5CpowwF9
R0KG3bX0AMRc2sfZDdTg0UOLiE8ZMV2prm/EpuaLyyNiJTW5/vpodbVuN55Soy2d
O46r1fsHHdNMT2VDYS0Z+kmY2BWMRgsCDkhj1HBby330XGym3TGgcU1dsxmsIm6Z
C84O7PiEOyM=
=yNYO
-----END PGP SIGNATURE-----

--=-ZEwXyXCb20IX49watm2+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
