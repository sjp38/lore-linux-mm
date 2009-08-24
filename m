Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 555EB6B0119
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 23:34:17 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2661360fxm.38
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 20:34:16 -0700 (PDT)
Message-ID: <4A929BF5.2050105@gmail.com>
Date: Mon, 24 Aug 2009 15:56:05 +0200
From: Stefan Huber <shuber2@gmail.com>
Reply-To: shuber2@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix hugetlb bug due to user_shm_unlock call (fwd)
References: <alpine.LRH.2.00.0908241110420.21562@tundra.namei.org> <Pine.LNX.4.64.0908241258070.27704@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908241258070.27704@sister.anvils>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enigE64C7769F176B869D162D009"
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Meerwald <pmeerw@cosy.sbg.ac.at>, James Morris <jmorris@namei.org>, William Irwin <wli@movementarian.org>, Mel Gorman <mel@csn.ul.ie>, Ravikiran G Thirumalai <kiran@scalex86.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE64C7769F176B869D162D009
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

> However, though I can well believe that your patch works well for you,
> I don't think it's general enough: there is no guarantee that the tests=

> in can_do_hugetlb_shm() will give the same answer to the user who ends
> up calling shm_destroy() as it did once upon a time to the user who
> called hugetlb_file_setup().
>=20
> So, please could you try this alternative patch below, to see if it
> passes your testing too, and let us know the result?  I'm sure we'd
> like to get a fix into 2.6.31, and into 2.6.30-stable.


Yes, your observation is right and your modified patch works good for
me.

So long
Stefan




--------------enigE64C7769F176B869D162D009
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEAREIAAYFAkqSm/oACgkQluL3b44/h0ofQwCeJ6vUjbAZZc13APFOUMZNOTbI
eqYAoKhtPiHynuffJAKHZFYjEDRgEpTQ
=mRoT
-----END PGP SIGNATURE-----

--------------enigE64C7769F176B869D162D009--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
