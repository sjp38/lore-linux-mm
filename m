Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re:
	Remove page flags for software suspend)
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <200703082354.46001.rjw@sisk.pl>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
	 <200703082333.06679.rjw@sisk.pl> <1173393815.3831.29.camel@johannes.berg>
	 <200703082354.46001.rjw@sisk.pl>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tNuwlaBOX2/ObDPm8lFC"
Date: Thu, 08 Mar 2007 23:54:51 +0100
Message-Id: <1173394491.3831.38.camel@johannes.berg>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

--=-tNuwlaBOX2/ObDPm8lFC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-03-08 at 23:54 +0100, Rafael J. Wysocki wrote:

> In that case your patch seems to be the simplest one and I think it shoul=
d go
> along with some code that will actually use it.

Right. So if anyone else needs it feel free to pick up my patch, if not
I'll submit it again as part of my "suspend on powermac G5" patchset
when that is properly reviewed by the appropriate people. Assuming, of
course, that this (yours) patchset is picked up.

johannes

--=-tNuwlaBOX2/ObDPm8lFC
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8JQ7/ETPhpq3jKURAkoQAKCaJVVg20dqWF+ddLHt0tSsbO7y/ACfSyya
TXNhhznkb0ygzgV1oxwF/aU=
=h+Kv
-----END PGP SIGNATURE-----

--=-tNuwlaBOX2/ObDPm8lFC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
