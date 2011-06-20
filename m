Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0DF6B0116
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:17:30 -0400 (EDT)
Received: by iwn8 with SMTP id 8so1445737iwn.14
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:17:27 -0700 (PDT)
Date: Mon, 20 Jun 2011 12:17:23 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH] mm: hugetlb: fix coding style issues
Message-ID: <20110620161723.GA9697@mgebm.net>
References: <1308299399-825-1-git-send-email-chrisf@ijw.co.nz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SLDf9lqlvOQaIe6s"
Content-Disposition: inline
In-Reply-To: <1308299399-825-1-git-send-email-chrisf@ijw.co.nz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Forbes <chrisf@ijw.co.nz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 17 Jun 2011, Chris Forbes wrote:

> Fixed coding style issues flagged by checkpatch.pl
>=20
> Signed-off-by: Chris Forbes <chrisf@ijw.co.nz>

Looks like whitespace/bracing cleanup without any logic changes (intentiona=
l or
otherwise).

Acked-by: Eric B Munson <emunson@mgebm.net>

--SLDf9lqlvOQaIe6s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN/3KTAAoJEH65iIruGRnNg6wH/0YRW3vYfeaNPZj6ou9Po9Ce
NbNYAqZ1dCGAoQj8mcvwATwEBDNVJWH9EkEIjKm1+qSsFuLtriMcHibgRGTbmr4D
a0/EaYR9S1Y9sQON1UGOEeNfpAUUdXCKsMsOf89RoUXVnobjBVATfeasjuL7jRlJ
SFHfupudiX9ummusak2jO3aeS6zrrkcyQOVTAfBL71NqogE0OOXSoO/CM7lTMMUh
qizshKMjO+BN79P75btQ5cUys8DtZxg3irWv3VRewN6GmxEujPKyT2PA7rL5q4oZ
z7zJk02tHfN9uWR1TjR7gLS0/khz5g9Y+fUoC7uoPDwvnCJZxVgtHroOf7FlbFk=
=3y/I
-----END PGP SIGNATURE-----

--SLDf9lqlvOQaIe6s--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
