Received: from 218-101-109-95.dialup.clear.net.nz
 (218-101-109-95.dialup.clear.net.nz [218.101.109.95])
 by smtp1.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0HRX004TK801GD@smtp1.clear.net.nz> for linux-mm@kvack.org; Fri,
 23 Jan 2004 15:24:03 +1300 (NZDT)
Date: Fri, 23 Jan 2004 15:26:53 +1300
From: Nigel Cunningham <ncunningham@users.sourceforge.net>
Subject: Can a page be HighMem without having the HighMem flag set?
Reply-to: ncunningham@users.sourceforge.net
Message-id: <1074824487.12774.185.camel@laptop-linux>
MIME-version: 1.0
Content-type: multipart/signed; boundary="=-xCMq03ux0VXVcqPq2vVF";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-xCMq03ux0VXVcqPq2vVF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi.

I guess the subject says it all, but I'll give more detail:

I'm working on Suspend on a 8 cpu ("8 way"?) SMP box at OSDL, which has
something in excess of 4GB, but I'm only using 4 at the moment:

Warning only 4GB will be used.
Use a PAE enabled kernel.
3200MB HIGHMEM available.
896MB LOWMEM available.

When suspending, I am seeing pages that don't have the HighMem flag set,
but for which page_address returns zero.

I looked at kmap, and noticed that it tests for page <
highmem_start_page; I guess this is the way to do it?

Regards,

Nigel
--=20
My work on Software Suspend is graciously brought to you by
LinuxFund.org.

--=-xCMq03ux0VXVcqPq2vVF
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAEIUnVfpQGcyBBWkRApycAJ0VZj2F2fW8uB52nmfbxRJ7Z14SGACgkird
1ktyEFe2BpNMFwbjbX0hffM=
=4YUR
-----END PGP SIGNATURE-----

--=-xCMq03ux0VXVcqPq2vVF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
