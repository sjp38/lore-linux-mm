Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7A46B005C
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 07:38:11 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6OBWfMC032200
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 07:32:41 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6OBc67b243070
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 07:38:07 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6OBZREX023447
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 07:35:28 -0400
Date: Fri, 24 Jul 2009 12:38:03 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: PCL event logging question
Message-ID: <20090724113803.GA6640@us.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RnlQjJ0d97Da+TV1"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: mingo@elte.hu, paulus@samba.org, a.p.zijlstra@chello.nl
Cc: mel@csn.ul.ie, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Sorry for the resend, I am not sure the first went out and I forgot to cc l=
ists.

I am looking at using the perf tool to collect data on TLB and cache misses
and there is one more piece of data that I need to collect over what is
currently available.  I would like to find the data address that caused the
miss, how can I go about capturing this when the miss event is logged?

Thanks

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--RnlQjJ0d97Da+TV1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkppnRsACgkQsnv9E83jkzobFwCghnr/xBcWjcB8hBsNJuZ93jX7
YqcAoKevvhEgMvbHy4eRliv8Jqzgitbc
=xrSa
-----END PGP SIGNATURE-----

--RnlQjJ0d97Da+TV1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
