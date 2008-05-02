Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m42Lg2il009503
	for <linux-mm@kvack.org>; Fri, 2 May 2008 17:42:02 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m42Likjt178596
	for <linux-mm@kvack.org>; Fri, 2 May 2008 15:44:49 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m42LikF3004364
	for <linux-mm@kvack.org>; Fri, 2 May 2008 15:44:46 -0600
Subject: Re: [RFC][PATCH 2/2] Add huge page backed stack support
From: Eric B Munson <ebmunson@us.ibm.com>
Reply-To: ebmunson@us.ibm.com
In-Reply-To: <1209748542.7763.39.camel@nimitz.home.sr71.net>
References: <1209693109.8483.23.camel@grover.beaverton.ibm.com>
	 <1209748542.7763.39.camel@nimitz.home.sr71.net>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xqI1FUYtNyooENdypwEH"
Date: Fri, 02 May 2008 14:44:45 -0700
Message-Id: <1209764685.8581.13.camel@grover.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-xqI1FUYtNyooENdypwEH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-05-02 at 10:15 -0700, Dave Hansen wrote:
> On Thu, 2008-05-01 at 18:51 -0700, Eric B Munson wrote
> > The GROWSUP and GROWSDOWN VM flags are turned off because a hugetlb bac=
ked
> > vma is not resizable, so it will be appropriately sized when created.  =
When
> > a process exceeds stack size it recieves a segfault exactly as it would=
 if it
> > exceeded the ulimit.
>=20
> This one is *really* subtle.  The segfault might behave like breaking a
> ulimit.  But, unlike a ulimit, you can't really work around this
> particular limitation very easily.

I must have not articulated the way things are working well enough.  The
vma that is created for the process stack is sized to hold ulimit /
HPAGE_SIZE huge pages if ulimit is not unlimited.  If ulimit is
unlimited it holds 256MB / HPAGE_SIZE pages.  256MB was picked because
it is a decent comprimise between large stacks and leaving some of a 32
bit address space available.  The segfault is as easily solved as
adjusting the ulimit for stack size.  If ulimit is raised the stack vma
will be bigger to match.  So it does behave exactly as base page stacks
would when you exceed the ulimit for stack size.

>=20
> This will really suck for anyone that tries to use 64k huge pages on
> powerpc, right?

Can you expand on this some, I am not sure what you are getting at.

>=20
> Are you actually looking to get this included, or are you just trying to
> play with this?  It is useful as a toy as-is, but I think you should
> look at fixing stack growing before it gets merged anywhere.

I am looking for comments and eventually to be merged.  What would take
to get something along this idea merged?  Is anyone completely opposed,
and if so why?

>=20
> -- Dave
>=20


--=-xqI1FUYtNyooENdypwEH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIG4tNsnv9E83jkzoRAqZDAJ9Fzlj0XG6qatF0mze6mWKdEHHHfgCdEnad
cKv0wAoM2rz7Ce4uGLeGdOU=
=ifAF
-----END PGP SIGNATURE-----

--=-xqI1FUYtNyooENdypwEH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
