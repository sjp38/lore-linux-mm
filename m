Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A471F8D003D
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 10:31:23 -0500 (EST)
Received: by mail-vw0-f41.google.com with SMTP id 13so3583840vws.14
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 07:31:22 -0800 (PST)
Date: Wed, 23 Feb 2011 10:30:41 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 2/5] break out smaps_pte_entry() from smaps_pte_range()
Message-ID: <20110223153041.GB2810@mgebm.net>
References: <20110222015338.309727CA@kernel>
 <20110222015340.B0D1C3FC@kernel>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z6Eq5LdranGa6ru8"
Content-Disposition: inline
In-Reply-To: <20110222015340.B0D1C3FC@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, akpm@osdl.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>


--z6Eq5LdranGa6ru8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 21 Feb 2011, Dave Hansen wrote:

>=20
> We will use smaps_pte_entry() in a moment to handle both small
> and transparent large pages.  But, we must break it out of
> smaps_pte_range() first.
>=20
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Reviewed-and-tested-by: Eric B Munson <emunson@mgebm.net>

--z6Eq5LdranGa6ru8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNZSghAAoJEH65iIruGRnNWd0IANso5VZqEYZ7IuOa8v6pKVIP
3Hp2AnvB2ZuZC/3t/v8xERXsaGSwl1MIWyhdqlvdkQxTNh5Z14Ivwq5EpkOpb5br
+F1gVk3XJCyUatCVj1iL4UTgg9FrBCrdOyvn5nq3/DBanoEjJzSibH3vlLhfX8Z8
D5P/pcim4o7IdWfVlbCwSyMBlnt4lpQVhL0gqRoUdZY7VbcBUMhf3BRnmCIwwPCJ
Y15K0h9WIhWysjmkT7uMFIVhJJiXDZTCDjyY70VDw2VbOCHF51yQr3TBHdXxrA82
Ps3XPrna2+H3fbv7NRCoyjahN6KetQqRrllE1NwdcPuZ6uCf5no+qFUCS5rQav8=
=4KaD
-----END PGP SIGNATURE-----

--z6Eq5LdranGa6ru8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
