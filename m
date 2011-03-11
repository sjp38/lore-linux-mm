Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 368FB8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 11:33:27 -0500 (EST)
Date: Fri, 11 Mar 2011 17:33:13 +0100
From: Jan Dvorak <mordae@anilinux.org>
Message-Id: <20110311173313.f427fb3b.mordae@anilinux.org>
In-Reply-To: <alpine.DEB.2.00.1103110914290.18585@router.home>
References: <056c7b49e7540a910b8a4f664415e638@anilinux.org>
	<alpine.DEB.2.00.1103101309090.2161@router.home>
	<faf1c53253ae791c39448de707b96c15@anilinux.org>
	<alpine.DEB.2.00.1103101532230.2161@router.home>
	<474da85b78a7bd1e16726b72e9162f5c@anilinux.org>
	<alpine.DEB.2.00.1103110914290.18585@router.home>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__11_Mar_2011_17_33_13_+0100_qc5V0z3tN=htyOo3"
Subject: Re: COW userspace memory mapping question
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org

--Signature=_Fri__11_Mar_2011_17_33_13_+0100_qc5V0z3tN=htyOo3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 11 Mar 2011 09:15:42 -0600 (CST), Christoph Lameter <cl@linux.com> =
wrote:
> Keep the RW mapping around and tear down and repeat the MAP_PRIVATE mmaps
> areas as needed? Updates would have to be done to the RW mapping.

Hmm, I can create a shared mapping and snapshot normally using the private
mapping. Only thing I need to do in order to ensure I will still see the
original state in the private map is to write something to it before every
update of the shared map. Is that correct?

--Signature=_Fri__11_Mar_2011_17_33_13_+0100_qc5V0z3tN=htyOo3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iEYEARECAAYFAk16TswACgkQBMrh4NcVzh/nIACgvwEAYzcwwEbTKTz3DYao8t57
qNsAn2yr5R0tCNCsq2C8k3vMijKXC9om
=EtX1
-----END PGP SIGNATURE-----

--Signature=_Fri__11_Mar_2011_17_33_13_+0100_qc5V0z3tN=htyOo3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
