Received: from 218-101-109-95.dialup.clear.net.nz
 (218-101-109-95.dialup.clear.net.nz [218.101.109.95])
 by smtp2.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0HRY003WYWT9ES@smtp2.clear.net.nz> for linux-mm@kvack.org; Sat,
 24 Jan 2004 13:17:36 +1300 (NZDT)
Date: Sat, 24 Jan 2004 13:20:25 +1300
From: Nigel Cunningham <ncunningham@users.sourceforge.net>
Subject: Re: Can a page be HighMem without having the HighMem flag set?
In-reply-to: <20040124000435.GC1016@holomorphy.com>
Reply-to: ncunningham@users.sourceforge.net
Message-id: <1074903624.2093.51.camel@laptop-linux>
MIME-version: 1.0
Content-type: multipart/signed; boundary="=-he0Bfb1YNsktdVPlWtRD";
 protocol="application/pgp-signature"; micalg=pgp-sha1
References: <1074824487.12774.185.camel@laptop-linux>
 <20040123022617.GY1016@holomorphy.com>
 <1074828647.12774.212.camel@laptop-linux>
 <1074900629.2024.44.camel@laptop-linux> <20040124000435.GC1016@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-he0Bfb1YNsktdVPlWtRD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

That's fine. I'll just ignore those pages for the sake of suspending and
resuming. I've just successfully suspended with those changes, but
suspending is the easy part.... resuming worked too :>

Regards,

Nigel

On Sat, 2004-01-24 at 13:04, William Lee Irwin III wrote:
> > It's the pages efff6000- which are causing me grief. if I understand
> > things correctly, page_is_ram is returning 0 for those pages, and as a
> > result they get marked reserved and not HighMem by one_highpage_init.
> > I suppose, then, that I need to check for and ignore pages >
> > highstart_pfn where PageHighMem is not set/Reserved is set. (Either
> > okay?).
>=20
> If it's reserved, most/all bets are off -- only the "owner" of the thing
> understands what it is. Some more formally-defined semantics for reserved
> are needed, but 2.6 is unlikely to get them soon.
>=20
>=20
> -- wli
--=20
My work on Software Suspend is graciously brought to you by
LinuxFund.org.

--=-he0Bfb1YNsktdVPlWtRD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAEbpIVfpQGcyBBWkRAi+AAKCXKyjMgs3OCI7Nerb0Nqaiay5nVwCgn44T
Ou3M6nUelTpJeVR+7dS3Sjg=
=WdbT
-----END PGP SIGNATURE-----

--=-he0Bfb1YNsktdVPlWtRD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
