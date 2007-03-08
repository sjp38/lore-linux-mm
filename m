Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re:
	Remove page flags for software suspend)
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <200703082310.15297.rjw@sisk.pl>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
	 <200703041450.02178.rjw@sisk.pl> <1173366543.3248.1.camel@johannes.berg>
	 <200703082310.15297.rjw@sisk.pl>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-H5VGwHT09kUgx4FcyzbV"
Date: Thu, 08 Mar 2007 23:12:38 +0100
Message-Id: <1173391958.3831.7.camel@johannes.berg>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Pavel Machek <pavel@ucw.cz>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

--=-H5VGwHT09kUgx4FcyzbV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-03-08 at 23:10 +0100, Rafael J. Wysocki wrote:

> > Works on my powerbook as well. Never mind that usb is broken again with
> > suspend to disk. And my own patches break both str and std right now.
>=20
> Ouch.

Actually. Some fluke or mismanagement of patches, my own patches are
fine (the suspend set I just gave you the link to). Probably screwed
something up during testing earlier.

> > But these (on top of wireless-dev which is currently about 2.6.21-rc2)
> > work fine as long as I assume they don't break usb ;)
>=20
> Well, on my boxes they don't. ;-)

Good :)
I think usb suspend is broken on my machine with and without these
patches but I haven't tested it. I may debug it more some time, or just
leave it since it works with str and I hardly ever std. Then again,
maybe it's fine in -rc3, I'm still at -rc2 (due to wireless-dev not
being up to date)

johannes

--=-H5VGwHT09kUgx4FcyzbV
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8IpW/ETPhpq3jKURAt5FAJ9JWSXRhO0tqQVythS20agm9rbBYwCeMjmj
ZMNWzG2dytKO4e+s+XW9tV0=
=7a/E
-----END PGP SIGNATURE-----

--=-H5VGwHT09kUgx4FcyzbV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
