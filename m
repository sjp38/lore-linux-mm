Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 79B9C6B0095
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 11:54:20 -0500 (EST)
Received: by pwj8 with SMTP id 8so635696pwj.14
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 08:54:14 -0800 (PST)
Date: Mon, 13 Dec 2010 09:54:05 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 1/6] mm: kswapd: Stop high-order balancing when any
 suitable zone is balanced
Message-ID: <20101213165405.GA3401@mgebm.net>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
 <1291893500-12342-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline
In-Reply-To: <1291893500-12342-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 09 Dec 2010, Mel Gorman wrote:

> When the allocator enters its slow path, kswapd is woken up to balance the
> node. It continues working until all zones within the node are balanced. =
For
> order-0 allocations, this makes perfect sense but for higher orders it can
> have unintended side-effects. If the zone sizes are imbalanced, kswapd may
> reclaim heavily within a smaller zone discarding an excessive number of
> pages. The user-visible behaviour is that kswapd is awake and reclaiming
> even though plenty of pages are free from a suitable zone.
>=20
> This patch alters the "balance" logic for high-order reclaim allowing ksw=
apd
> to stop if any suitable zone becomes balanced to reduce the number of pag=
es
> it reclaims from other zones. kswapd still tries to ensure that order-0
> watermarks for all zones are met before sleeping.
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Looks good to me.

Reviewed-by: Eric B Munson <emunson@mgebm.net>

--x+6KMIRAuhnl3hBn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNBk+tAAoJEH65iIruGRnN2UoIAJAVhQyLzVEJO3bRcprOcF32
6nu2UwoACYmA3ge+eMjaOdqaZ/GW2XNIW6n211oGUmZt1ttRihOxRPDhxqUkCYf6
O32MwxEdSf61I1icQlEnj7+fP0UMES8h5e0hi2Aq3LXo82aTgUa4CuCeI8RqMpMv
lcGm4/dilzG0l4TNt0GfxiI4xeZu5+A2mDAsVyTd+77d3A0GxszptXlKf3NbSKJn
au5sCS5E+aqHNkqXfrTzPM0HzxXeVvd12RZJYiF6WfTXs29CV0cHIs/gHAb5cYlu
b4yQX20HId2YuFjl5UhszOSXYj2Gsw4Bhk/ZArKWMdAqQCkui+njxql+uHjym6w=
=zXJi
-----END PGP SIGNATURE-----

--x+6KMIRAuhnl3hBn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
