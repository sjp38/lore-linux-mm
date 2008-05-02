Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m421pIrF020687
	for <linux-mm@kvack.org>; Thu, 1 May 2008 21:51:18 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m421pIwN196096
	for <linux-mm@kvack.org>; Thu, 1 May 2008 19:51:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m427pIRS029304
	for <linux-mm@kvack.org>; Fri, 2 May 2008 01:51:18 -0600
Subject: [RFC][PATCH 0/2] Huge page backed user-space stacks
From: Eric B Munson <ebmunson@us.ibm.com>
Reply-To: ebmunson@us.ibm.com
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-t4NLSwivW/otG6l6j2bI"
Date: Thu, 01 May 2008 18:51:16 -0700
Message-Id: <1209693076.8483.21.camel@grover.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-t4NLSwivW/otG6l6j2bI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

It is beneficial for certain user space processes to use huge pages for
their process stacks rather than small pages.

Presently there is no way for a process to do this.  This patch set
introduces a method for putting user space process stacks on huge pages.
It adds a personality flag that requests huge page backed stacks.  A
user space utility will be required to set the personality flag before
calling exec with for the target process.

--=-t4NLSwivW/otG6l6j2bI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIGnOUsnv9E83jkzoRAnuUAJ0RlXOGXND+/L2TRbuEomOoUREZjwCfaDI3
djW+o44uDPA+eBh+pmKu6FM=
=Ya8z
-----END PGP SIGNATURE-----

--=-t4NLSwivW/otG6l6j2bI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
