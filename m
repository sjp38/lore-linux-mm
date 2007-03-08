Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re:
	Remove page flags for software suspend)
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20070308231512.GB1977@elf.ucw.cz>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
	 <200703041450.02178.rjw@sisk.pl> <1173315625.3546.32.camel@johannes.berg>
	 <200703082305.43513.rjw@sisk.pl>  <20070308231512.GB1977@elf.ucw.cz>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0+7od6/IuhrtZwpZSSog"
Date: Fri, 09 Mar 2007 00:21:34 +0100
Message-Id: <1173396094.3831.42.camel@johannes.berg>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

--=-0+7od6/IuhrtZwpZSSog
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-03-09 at 00:15 +0100, Pavel Machek wrote:

> That's a no-no. ATOMIC alocations can fail, and no, WARN_ON is not
> enough. It is not a bug, they just fail.

But like I said in my post, there's no way we can disable suspend to
disk when they do, right now anyway. Also, this can't be called any
later than a late initcall or such since it's __init, and thus there
shouldn't be memory pressure yet that would cause this to fail.

In any case, I'd be much happier with having a "disable suspend"
variable so we could print a big warning and set that flag.

johannes

--=-0+7od6/IuhrtZwpZSSog
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8Jp+/ETPhpq3jKURAqVJAJ4qbLd+yOSv8ZeEegAJXIzydjCNdwCgrTpL
f5df6oWJNCS9ClQeJ5R+Zm4=
=hmli
-----END PGP SIGNATURE-----

--=-0+7od6/IuhrtZwpZSSog--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
