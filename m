Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 11B2A8D003E
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 10:31:11 -0500 (EST)
Received: by mail-vw0-f41.google.com with SMTP id 13so3583840vws.14
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 07:31:09 -0800 (PST)
Date: Wed, 23 Feb 2011 10:31:04 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 4/5] teach smaps_pte_range() about THP pmds
Message-ID: <20110223153104.GD2810@mgebm.net>
References: <20110222015338.309727CA@kernel>
 <20110222015343.41586948@kernel>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KdquIMZPjGJQvRdI"
Content-Disposition: inline
In-Reply-To: <20110222015343.41586948@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, akpm@osdl.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>


--KdquIMZPjGJQvRdI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 21 Feb 2011, Dave Hansen wrote:

>=20
> v2 - used mm->page_table_lock to fix up locking bug that
> 	Mel pointed out.  Also remove Acks since things
> 	got changed significantly.
>=20
> This adds code to explicitly detect  and handle
> pmd_trans_huge() pmds.  It then passes HPAGE_SIZE units
> in to the smap_pte_entry() function instead of PAGE_SIZE.
>=20
> This means that using /proc/$pid/smaps now will no longer
> cause THPs to be broken down in to small pages.
>=20
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Reviewed-and-tested-by: Eric B Munson <emunson@mgebm.net>

--KdquIMZPjGJQvRdI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNZSg4AAoJEH65iIruGRnNvSsH/AtwBQIVUaJi8Uvm59aCnIiu
ignraJxSzfqLoUkbGbA2prdsZwY0rk5Dn0Zdm1kzjpD+26YsA9n5JSdPFdzR7TXP
Srr/Yqs+rgPJPvKE6gJt1jXN8Rtxg1nE1TKxNKHJYHVnH/sLN1MQeSOFrbtBM7sq
Pil5w7FUII1ZpR/4BAq6fFEohyveXAGVHxZjfHkQNgfW6wP8Wxfulbb/QAf5W4/y
2FzSIrcDB45IT7c1drWX6zCqURXxOQHuJbye1xNK8XMANOWyfPeUJQeGj0yVd4T1
5cTXlP2pvYCB49dKmGRJSrtMXEHrF/F6Yv7NEw4M1PYHVLWbV96AevInnin8CNU=
=zbue
-----END PGP SIGNATURE-----

--KdquIMZPjGJQvRdI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
