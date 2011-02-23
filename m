Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 165A88D003D
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 10:34:27 -0500 (EST)
Received: by vws13 with SMTP id 13so3588918vws.14
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 07:34:07 -0800 (PST)
Date: Wed, 23 Feb 2011 10:33:30 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH v2] hugetlbfs: correct handling of negative input to
 /proc/sys/vm/nr_hugepages
Message-ID: <20110223153330.GF2810@mgebm.net>
References: <4D6419C0.8080804@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9ADF8FXzFeE7X4jE"
Content-Disposition: inline
In-Reply-To: <4D6419C0.8080804@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org


--9ADF8FXzFeE7X4jE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 22 Feb 2011, Petr Holasek wrote:

> When user insert negative value into /proc/sys/vm/nr_hugepages it
> will result
> in the setting a random number of HugePages in system (can be easily show=
ed
> at /proc/meminfo output). This patch fixes the wrong behavior so that the
> negative input will result in nr_hugepages value unchanged.
>=20
> v2: same fix was also done in hugetlb_overcommit_handler function
>     as suggested by reviewers.
>=20
> Signed-off-by: Petr Holasek <pholasek@redhat.com>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Eric B Munson <emunson@mgebm.net>

--9ADF8FXzFeE7X4jE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNZSjKAAoJEH65iIruGRnNfmgIANcaLoAQV6ayXUnWTeYd1BtW
xjf2c91jcxg+UMRNmpZEkQXVU03CfV4GZe/o9r1vXDTZTtUgMYpRcI+dhIC7X4+W
IhiPQAB1I/J0E8vNvYfbj7J2GK7vvmMhM1du3DQyb44L5IsbNiaA13VfCrUqTS+g
3Ls6SROHpQOc/Qf4EXsq0w6nrrlJfOFajLJ7LNA6EAd59Ze6mA0QaBrARyOmpjYe
IPQZbPB5IKcy64+1rnTjrDgd9ba1ruhOKVsrb0q0u7z1LO7a+K9IhPMVpPNkydeS
8bHUWdQCnH0NdHkWggTPdJac82e5JGWddcjoNi5JYx5/QqNLkWqIgVDA+kXg3hQ=
=QDU0
-----END PGP SIGNATURE-----

--9ADF8FXzFeE7X4jE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
