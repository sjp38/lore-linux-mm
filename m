Subject: Re: [PATCH 3/3] Add arch-specific walk_memory_remove() for ppc64
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1193849335.17412.33.camel@dyn9047017100.beaverton.ibm.com>
References: <1193849335.17412.33.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cAlWIPTGfxae2J1IDv6p"
Date: Fri, 02 Nov 2007 10:32:10 +0000
Message-Id: <1193999530.25744.3.camel@johannes.berg>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-cAlWIPTGfxae2J1IDv6p
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> This patch provides a way for an architecture to provide its
> own walk_memory_resource()

It seems that the patch description "walk_memory_remove()" is wrong?

johannes

--=-cAlWIPTGfxae2J1IDv6p
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARyr8qaVg1VMiehFYAQIq2A//SUYdZ2Kox7TSLno9s1odL3iQqXat3DTo
IWYDX0ErgzWM+i6sVE1hMyZtvGv2fuUOioAnzMEj8nui8Qp4n3Rvr1aiPuUZcV5X
c6wQ8BNqFhXcoIZjaJH3efhOQ673AHLcgyyWl48n+uSOQXFaE1Ljw8s7/IF/OLlZ
SpGy3E7LTbGHD5liOTIHXAphIQtWTuATKg9brjW88SwGzoe8pkBBRhSpet93Lfrh
S5IbR23u8QKlD5g7J6wLiMQ76A/VZg14DK8gUi8DX2ebZG6bBYmxjWf4uOW1qvuE
ZNQa71QNrPenInCc1KlvYRbiGYQ4Rdfc5ENsEBtgFc80KLpMVC+ILL0DNwk2jk5H
2snGA3wSeYANZCuxlrxLH+IhI413Dy7ckjnIC4pZ4RTMWhYn1xDye6rumhBrFAbX
dlSOkOntctUHCNcagJE7Rg6jOJGjuuoz+MRrlvpMFzuV2avpy3/BJSCSoGUQVJLk
02w0TSlyLnIEaNXrTIz2UpA4THgpe0Ynnl9DhNGfPhmrZDlMtf1wONf0VIx3S1Zj
18qbazsMxrMxo0VwVjGdHAOnGmefVGYLr86K7elqrpOtQGrgcxXpQ0jF4FuAv9ak
tkLcb4RZZTA1HLT+nt+SEwRcatmWatUB2G1M1dDrUd4Me/9MwWNxIlckKvTE/pS2
CizlORweXsc=
=RYg6
-----END PGP SIGNATURE-----

--=-cAlWIPTGfxae2J1IDv6p--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
