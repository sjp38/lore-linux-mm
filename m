Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F3FBC6B0096
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 14:39:13 -0500 (EST)
Received: by pvb32 with SMTP id 32so1316204pvb.2
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 11:39:12 -0800 (PST)
Date: Mon, 13 Dec 2010 12:39:05 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 4/6] mm: kswapd: Reset kswapd_max_order and
 classzone_idx after reading
Message-ID: <20101213193905.GF3401@mgebm.net>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
 <1291995985-5913-5-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xkXJwpr35CY/Lc3I"
Content-Disposition: inline
In-Reply-To: <1291995985-5913-5-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--xkXJwpr35CY/Lc3I
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 10 Dec 2010, Mel Gorman wrote:

> When kswapd wakes up, it reads its order and classzone from pgdat and
> calls balance_pgdat. While its awake, it potentially reclaimes at a high
> order and a low classzone index. This might have been a once-off that
> was not required by subsequent callers. However, because the pgdat
> values were not reset, they remain artifically high while
> balance_pgdat() is running and potentially kswapd enters a second
> unnecessary reclaim cycle. Reset the pgdat order and classzone index
> after reading.
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Eric B Munson <emunson@mgebm.net>

--xkXJwpr35CY/Lc3I
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNBnZZAAoJEH65iIruGRnNrHAH/Aw66XlKoMoMRry7tUzLuLU4
wa7y5Ghdd2A/9i67SCLOfzwOtrjD8eW1fOqIXfUAOG7dG8JxYPPfugB39Ej8bMv8
6r0Q5h96g7J2v3njEo+AJfqZsxC/v0501oZV3okrUNq2QASRn5mBc6bIFPDes1EE
UhciwF7rigD9yDuY2C0wDwjNyyoWLxF0Wy+ByTbUwexhLG9P0Ylt5cyAArHLEIUb
eeD8Vq9NGH1zmDTch9xe5C+/G4zyv+MHykMZ6z2fqS8yA+sjSPAKN6lkY4sH5hEc
HEjxUjjRa7zoH4nNeiJLHdyGqYPbdU1PM3TvZLF8rE0mjfb6JZhuTO/BBGI4Pyk=
=iLw9
-----END PGP SIGNATURE-----

--xkXJwpr35CY/Lc3I--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
