Date: Fri, 30 Jan 2004 06:14:36 -0500
From: "Zephaniah E. Hull" <warp@babylon.d2dc.net>
Subject: Re: 2.6.2-rc2-mm2
Message-ID: <20040130111435.GB2505@babylon.d2dc.net>
References: <20040130014108.09c964fd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/WwmFnJnmDyWGHa4"
Content-Disposition: inline
In-Reply-To: <20040130014108.09c964fd.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--/WwmFnJnmDyWGHa4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 30, 2004 at 01:41:08AM -0800, Andrew Morton wrote:
>=20
>=20
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2-rc2/2=
=2E6.2-rc2-mm2/
>=20
>=20
> - I added a few late-arriving patches.  Usually this breaks things.
>=20
> - Added a few external development trees (USB, XFS).
>=20
> - PNP update

This patch contains:
--- linux-2.6.2-rc2/./include/linux/sched.h	2004-01-25 20:49:43.000000000 -=
0800
+++ 25/./include/linux/sched.h	2004-01-29 23:27:45.000000000 -0800
=2E..
--- linux-2.6.2-rc2/include/linux/sched.h	2004-01-25 20:49:43.000000000 -08=
00
+++ 25/include/linux/sched.h	2004-01-29 23:27:45.000000000 -0800

Both of which seem to be the exact same patch.

This obviously causes some problems when applying.

--=20
	1024D/E65A7801 Zephaniah E. Hull <warp@babylon.d2dc.net>
	   92ED 94E4 B1E6 3624 226D  5727 4453 008B E65A 7801
	    CCs of replies from mailing lists are requested.

This is commonly attributed to the lusers spending too much time talking
with their BOFH. They start thinking their name is "Moron" or "Dimwit"
because you keep calling them that.  -- Toni Lassila <toni@nukespam.org>
    in the Scary Devil Monastery about lusers forgetting their own names

--/WwmFnJnmDyWGHa4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAGjybRFMAi+ZaeAERApnnAKCBL/y1e1lMAcjouF/KVClZvV00MwCdE2Oa
9zIGCT3m+8003pztPXVKOA8=
=P4KP
-----END PGP SIGNATURE-----

--/WwmFnJnmDyWGHa4--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
