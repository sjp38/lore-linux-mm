Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EB4BE6B00EF
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 11:24:40 -0400 (EDT)
Received: by yia13 with SMTP id 13so1664710yia.14
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 08:24:39 -0700 (PDT)
Date: Mon, 18 Jul 2011 11:24:34 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 1/2] hugepage: Protect region tracking lists with its own
 spinlock
Message-ID: <20110718152434.GA3890@mgebm.net>
References: <20110125143226.37532ea2@kryten>
 <20110125143414.1dbb150c@kryten>
 <20110126092428.GR18984@csn.ul.ie>
 <20110715160650.48d61245@kryten>
 <20110715160852.0d16318a@kryten>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6c2NcOVqGQ03X4Wi"
Content-Disposition: inline
In-Reply-To: <20110715160852.0d16318a@kryten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: Mel Gorman <mel@csn.ul.ie>, dwg@au1.ibm.com, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 15 Jul 2011, Anton Blanchard wrote:

>=20
> In preparation for creating a hash of spinlocks to replace the global
> hugetlb_instantiation_mutex, protect the region tracking code with
> its own spinlock.
>=20
> Signed-off-by: Anton Blanchard <anton@samba.org>=20

These work on x86_64 as well with the same test method as described by Anto=
n.

Tested-by: Eric B Munson <emunson@mgebm.net>

--6c2NcOVqGQ03X4Wi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOJFAyAAoJEH65iIruGRnNl40IAIESxMzphGy3lxxzxvre5DIg
liqsAotlTHNgpUDZKzgH6LGm4ADtL1bDvqMNG+VwD91OO+8tT5oxErJSeeFMaMWi
4rBEvykOp2G5LlObmhQY7fl4S9wEIeIoMh0joC+KLlr53TrlkRsfLoLMstZXNEJ1
Af7mL63KrpxTpvl/rrChlVJEaWAv2Nt2Cr3LLflyeLLDPmh8U27IAOhpce8fhu0Y
q4xlKidPw9ayPUn4vgIYTF7PzFsNqKGtqPkrmXhCI7nvsJcstu6SIFKTaN0c1TL7
T+seYzKtpHCi1q01WbtxAXVTfQYyprTvmSxJXSyTShlDIJV3czjxQ5/rDGS1uOw=
=tgA4
-----END PGP SIGNATURE-----

--6c2NcOVqGQ03X4Wi--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
