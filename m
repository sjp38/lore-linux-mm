Received: from 218-101-109-95.dialup.clear.net.nz
 (218-101-109-95.dialup.clear.net.nz [218.101.109.95])
 by smtp2.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0HRX0085H8WXOB@smtp2.clear.net.nz> for linux-mm@kvack.org; Fri,
 23 Jan 2004 15:43:47 +1300 (NZDT)
Date: Fri, 23 Jan 2004 15:46:37 +1300
From: Nigel Cunningham <ncunningham@users.sourceforge.net>
Subject: Re: Can a page be HighMem without having the HighMem flag set?
In-reply-to: <20040123022617.GY1016@holomorphy.com>
Reply-to: ncunningham@users.sourceforge.net
Message-id: <1074825996.12773.189.camel@laptop-linux>
MIME-version: 1.0
Content-type: multipart/signed; boundary="=-kCSPTbmsmA0mx4lCk2Ti";
 protocol="application/pgp-signature"; micalg=pgp-sha1
References: <1074824487.12774.185.camel@laptop-linux>
 <20040123022617.GY1016@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-kCSPTbmsmA0mx4lCk2Ti
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Okay. I'll see what I can do.

Regards,

Nigel

On Fri, 2004-01-23 at 15:26, William Lee Irwin III wrote:
> On Fri, Jan 23, 2004 at 03:26:53PM +1300, Nigel Cunningham wrote:
> > I guess the subject says it all, but I'll give more detail:
> > I'm working on Suspend on a 8 cpu ("8 way"?) SMP box at OSDL, which has
> > something in excess of 4GB, but I'm only using 4 at the moment:
> > Warning only 4GB will be used.
> > Use a PAE enabled kernel.
> > 3200MB HIGHMEM available.
> > 896MB LOWMEM available.
> > When suspending, I am seeing pages that don't have the HighMem flag set=
,
> > but for which page_address returns zero.
> > I looked at kmap, and noticed that it tests for page <
> > highmem_start_page; I guess this is the way to do it?
>=20
> You have found a bug. Could you chase down the inconsistency please?
>=20
>=20
> -- wli
--=20
My work on Software Suspend is graciously brought to you by
LinuxFund.org.

--=-kCSPTbmsmA0mx4lCk2Ti
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAEIsMVfpQGcyBBWkRAtBPAJ4mUdQCxSNnPJH9+2PqEUGO7Vt/agCghpOG
grzU+AOmvXqGVTrdQaIzeEs=
=smxr
-----END PGP SIGNATURE-----

--=-kCSPTbmsmA0mx4lCk2Ti--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
