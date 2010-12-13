Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 04EE06B0096
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 14:43:49 -0500 (EST)
Received: by pzk3 with SMTP id 3so617289pzk.2
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 11:43:48 -0800 (PST)
Date: Mon, 13 Dec 2010 12:43:41 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 6/6] mm: kswapd: Use the classzone idx that kswapd was
 using for sleeping_prematurely()
Message-ID: <20101213194341.GH3401@mgebm.net>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
 <1291995985-5913-7-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zq44+AAfm4giZpo5"
Content-Disposition: inline
In-Reply-To: <1291995985-5913-7-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--zq44+AAfm4giZpo5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 10 Dec 2010, Mel Gorman wrote:

> When kswapd is woken up for a high-order allocation, it takes account of
> the highest usable zone by the caller (the classzone idx). During
> allocation, this index is used to select the lowmem_reserve[] that
> should be applied to the watermark calculation in zone_watermark_ok().
>=20
> When balancing a node, kswapd considers the highest unbalanced zone to be=
 the
> classzone index. This will always be at least be the callers classzone_idx
> and can be higher. However, sleeping_prematurely() always considers the
> lowest zone (e.g. ZONE_DMA) to be the classzone index. This means that
> sleeping_prematurely() can consider a zone to be balanced that is unusable
> by the allocation request that originally woke kswapd. This patch changes
> sleeping_prematurely() to use a classzone_idx matching the value it used
> in balance_pgdat().
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: Eric B Munson <emunson@mgebm.net>

--zq44+AAfm4giZpo5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNBndtAAoJEH65iIruGRnNAR4IAJ0ppy0Hk9MvbVhCmaMHT07l
DcwjFis/RFmu2Zpzrjn3pmfahkkCOesSBeplehiqGnzEW+E8hKeyQ3KgGtlscTDb
CWyVgjgMihb4L7MWv5+lfrjL8/JBUQy0415m0Ea0bIoqwI9zDtl5mHVugVs6R+wL
QwNMriEr0C0ov4N2t3OxvL9FmYLVmf8hdgAebMHoq0pICtPHRx2zcIyXmREc42ow
DOC1QZgeGu5B0DXK9eBeEpf53NHynUHYN74o9FIhnnyBDxrtvD7QksJJRGc2DtkC
KYrHfrHuqhLEX/cZBh0VPGemHPpIBs06ejt6DhjpPdpsGgkNZ04qmkTyPUQtvLk=
=ieDW
-----END PGP SIGNATURE-----

--zq44+AAfm4giZpo5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
