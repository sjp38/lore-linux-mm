Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re:
	Remove page flags for software suspend)
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <200703041450.02178.rjw@sisk.pl>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
	 <45E6EEC5.4060902@yahoo.com.au> <200703011633.54625.rjw@sisk.pl>
	 <200703041450.02178.rjw@sisk.pl>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tg6Y6JTKtqyyHRYuNFvM"
Date: Thu, 08 Mar 2007 16:09:03 +0100
Message-Id: <1173366543.3248.1.camel@johannes.berg>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

--=-tg6Y6JTKtqyyHRYuNFvM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Okay, the next three messages contain patches that should do the trick.
>=20
> They have been tested on x86_64, but not very thoroughly.

Works on my powerbook as well. Never mind that usb is broken again with
suspend to disk. And my own patches break both str and std right now.

But these (on top of wireless-dev which is currently about 2.6.21-rc2)
work fine as long as I assume they don't break usb ;)

johannes

--=-tg6Y6JTKtqyyHRYuNFvM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8CcP/ETPhpq3jKURArA5AKCxPQpBgmSav9hwcHE+NRb4WAWJYQCfW6Cl
zASVP9lneXImRQUyn+hlQOc=
=s9WX
-----END PGP SIGNATURE-----

--=-tg6Y6JTKtqyyHRYuNFvM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
