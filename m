Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3EE3E6B0096
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 14:41:10 -0500 (EST)
Received: by pzk3 with SMTP id 3so617054pzk.2
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 11:40:55 -0800 (PST)
Date: Mon, 13 Dec 2010 12:40:47 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 5/6] mm: kswapd: Treat zone->all_unreclaimable in
 sleeping_prematurely similar to balance_pgdat()
Message-ID: <20101213194047.GG3401@mgebm.net>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
 <1291995985-5913-6-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RMedoP2+Pr6Rq0N2"
Content-Disposition: inline
In-Reply-To: <1291995985-5913-6-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--RMedoP2+Pr6Rq0N2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 10 Dec 2010, Mel Gorman wrote:

> After DEF_PRIORITY, balance_pgdat() considers all_unreclaimable zones to
> be balanced but sleeping_prematurely does not. This can force kswapd to
> stay awake longer than it should. This patch fixes it.
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: Eric B Munson <emunson@mgebm.net>

--RMedoP2+Pr6Rq0N2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNBna/AAoJEH65iIruGRnNUC8IAIv/gHOr5hMbbr+j2VeoaBDp
WZAv+whu//uAGrEYjo6aa+KNouBwvn+xnlpy3FFKZa42tiHduO8o1PT3WN5/6WPL
Sj2Am3NveFf1HomT59+Zu8cSNje0xP297erigL+fxQqLpy18R35xEkirkgDjEl8y
W00r3kJ5EK1NDyckpWdlreCqoC+dCpz/AgfQ3U9PXiRRR1kGikju45rT2njf5N20
AX6RXiLQNR/4+VJIVhFBgn/AiqWM5x8U6+HQxQD7Yy8EFN4I0pcdEPiohjIci98e
LCma82tDgQAjgSDRRx9+DsXlftgV9UXa7kxW3PpEeBufaGJ4ui1FKxPhKSvLpd4=
=XzDQ
-----END PGP SIGNATURE-----

--RMedoP2+Pr6Rq0N2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
