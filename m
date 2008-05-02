Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m42Lqp5b032141
	for <linux-mm@kvack.org>; Fri, 2 May 2008 17:52:51 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m42LqoPi176904
	for <linux-mm@kvack.org>; Fri, 2 May 2008 15:52:50 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m42LqoxK024561
	for <linux-mm@kvack.org>; Fri, 2 May 2008 15:52:50 -0600
Subject: Re: [RFC][PATCH 2/2] Add huge page backed stack support
From: Eric B Munson <ebmunson@us.ibm.com>
Reply-To: ebmunson@us.ibm.com
In-Reply-To: <1209748835.7763.41.camel@nimitz.home.sr71.net>
References: <1209693109.8483.23.camel@grover.beaverton.ibm.com>
	 <1209748286.7763.34.camel@nimitz.home.sr71.net>
	 <1209748835.7763.41.camel@nimitz.home.sr71.net>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Rp8N2nGEwz/IhRwdd9Xs"
Date: Fri, 02 May 2008 14:52:49 -0700
Message-Id: <1209765169.8581.14.camel@grover.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-Rp8N2nGEwz/IhRwdd9Xs
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-05-02 at 10:20 -0700, Dave Hansen wrote:
> On Fri, 2008-05-02 at 10:11 -0700, Dave Hansen wrote:
> > Why don't huge page stacks need to be expanded like this?  With a large
> > EXTRA_STACK_VM_PAGES, you would surely need this, right?
>=20
> Never mind.  You don't expand stacks.  This one is probably worth a
> comment.

Okay, I will add one for the next version.

>=20
> -- Dave
>=20


--=-Rp8N2nGEwz/IhRwdd9Xs
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIG40xsnv9E83jkzoRAtl3AKCP2Ga+0VH/FaXLMrBVHFJNhbISVwCeMkdV
YGs+EPtYipdnI8s/oELbgy8=
=Vimm
-----END PGP SIGNATURE-----

--=-Rp8N2nGEwz/IhRwdd9Xs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
