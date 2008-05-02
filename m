Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m42Lt2bt021628
	for <linux-mm@kvack.org>; Fri, 2 May 2008 17:55:02 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m42Lt2lk392138
	for <linux-mm@kvack.org>; Fri, 2 May 2008 17:55:02 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m42Lt2PC001282
	for <linux-mm@kvack.org>; Fri, 2 May 2008 17:55:02 -0400
Subject: Re: [RFC][PATCH 1/2] Add shared and reserve control to
	hugetlb_file_setup
From: Eric B Munson <ebmunson@us.ibm.com>
Reply-To: ebmunson@us.ibm.com
In-Reply-To: <1209744977.7763.29.camel@nimitz.home.sr71.net>
References: <1209693089.8483.22.camel@grover.beaverton.ibm.com>
	 <1209744977.7763.29.camel@nimitz.home.sr71.net>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uS9HryJMvyy0MUQb0LR0"
Date: Fri, 02 May 2008 14:55:01 -0700
Message-Id: <1209765301.8581.18.camel@grover.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-uS9HryJMvyy0MUQb0LR0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-05-02 at 09:16 -0700, Dave Hansen wrote:
> On Thu, 2008-05-01 at 18:51 -0700, Eric B Munson wrote:
> > In order to back stacks with huge pages, we will want to make hugetlbfs
> > files to back them; these will be used to back private mappings.
> > Currently hugetlb_file_setup creates files to back shared memory segmen=
ts.
> > Modify this to create both private and shared files,
>=20
> Hugetlbfs can currently have private mappings, right?  Why not just use
> the existing ones instead of creating a new variety with
> hugetlb_file_setup()?
>=20
> -- Dave
>=20

Currently the only way to create a private mapping of a huge page is to
have the file system mounted.  This change allows a huge page private
mapping without mounting the filesystem.

Eric

--=-uS9HryJMvyy0MUQb0LR0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIG421snv9E83jkzoRAinoAJ4jdgqPEGUT40B9e4pGkychWW195ACgnYu3
W44r6Pd3AaZ8x30o8F4KdTQ=
=qu94
-----END PGP SIGNATURE-----

--=-uS9HryJMvyy0MUQb0LR0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
