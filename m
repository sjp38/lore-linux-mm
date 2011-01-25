Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A0EAD6B00E9
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 14:43:13 -0500 (EST)
Received: by gxk5 with SMTP id 5so2068892gxk.14
        for <linux-mm@kvack.org>; Tue, 25 Jan 2011 11:43:11 -0800 (PST)
Date: Tue, 25 Jan 2011 12:43:05 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 1/2] hugepage: Protect region tracking lists with its
 own spinlock
Message-ID: <20110125194305.GA3041@mgebm.net>
References: <20110125143226.37532ea2@kryten>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cWoXeonUoKmBZSoM"
Content-Disposition: inline
In-Reply-To: <20110125143226.37532ea2@kryten>
Sender: owner-linux-mm@kvack.org
To: Anton Blanchard <anton@samba.org>
Cc: dwg@au1.ibm.com, mel@csn.ul.ie, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 25 Jan 2011, Anton Blanchard wrote:

>=20
> In preparation for creating a hash of spinlocks to replace the global
> hugetlb_instantiation_mutex, protect the region tracking code with
> its own spinlock.
>=20
> Signed-off-by: Anton Blanchard <anton@samba.org>=20

Reviewed-by: Eric B Munson <emunson@mgebm.net>

--cWoXeonUoKmBZSoM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNPyfJAAoJEH65iIruGRnNwLQH/17T2WJC8w2z70KCfhHpNS1K
5HoO+DTOw+a+j4tJ2STov2nPhv9g8L20dDuPq24EPBVbGuVSAbUXUSE4a44B2Is6
thYdwq86uhQDJtaO/EWjW6ZgwxHjl1umAtKYE0tSyxoVQns5eKZw+qPH1x6ivuBn
cTQKtvqNihul+avFuuAXR6EWA9pknAJlqR94ns4oH9lGDnd8rfAhGYT6ea9ETgKH
UA2OC9eggYa7w7MnVrBao38n5QKVMX9oNXzmHe4WAHqa9xtY8HdR5fvLmm3+yOo0
/Bom28ZI34HYPvKQPQv7/gqpBjpCazn58kB/5pLtxFSm2o5lcZfy/G6DbOBGwYo=
=aOOG
-----END PGP SIGNATURE-----

--cWoXeonUoKmBZSoM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
