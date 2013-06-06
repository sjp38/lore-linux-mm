Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 8CE286B0034
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 22:04:59 -0400 (EDT)
Date: Thu, 6 Jun 2013 12:04:55 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2013-06-05-17-24 uploaded
Message-Id: <20130606120455.bd86a4c0ac009482db80f634@canb.auug.org.au>
In-Reply-To: <20130606002636.6746F5A41AE@corp2gmr1-2.hot.corp.google.com>
References: <20130606002636.6746F5A41AE@corp2gmr1-2.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__6_Jun_2013_12_04_55_+1000_4uFTmUaO3h/okSgd"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

--Signature=_Thu__6_Jun_2013_12_04_55_+1000_4uFTmUaO3h/okSgd
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, 05 Jun 2013 17:26:36 -0700 akpm@linux-foundation.org wrote:
>
>   linux-next-git-rejects.patch

We must figure out why you sometimes get rejects that I do not get when I
import your series into a git tree.  However in this case you resolution
is not quite right.  It leaves 2 continue statements in
net/mac80211/iface.c at line 191 which will unconditionally short circuit
the enclosing loop.  The version that will be in linux-next today is
correct (and git did it automatically as part of the merge of the old
linux-next tree).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__6_Jun_2013_12_04_55_+1000_4uFTmUaO3h/okSgd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRr+5HAAoJEECxmPOUX5FEOo8P/RnG5/O6F33VHBHkewwwihE2
Ba9P9wfOy2DsgdIBvdSOcRaDE//2SFMheEbBdt1oFKWrPY1iycjn5NW1nqv4w051
o+3JUcIJM8ApjhO4oXBuLoZdHI9MrGg8l57GoOqOvZSANHhJfHovEXTGVw/xKRHk
p3cQ2YcnpwXiSf4BCWs/DniF7Ux3ETLomaEBwdd0Bg4Oqk64hfmXz3VDb9gJBCAT
eCQ1wu6cLd/rAGOJuxHHpx2cNPp7xr+fhEWRi0krEhAOlRkn1qQLCPkNRx9DpB7m
q0NTEf2nKzSwhYsKtspFJnl6aLyN91axuVF7m2nIa7E3BddJRCdCQIn5jlpB0ZwF
xGX9lO2jM/fWoNMgadjeqmyrzlAFtUvLliTQSANz4GMoalhnGBuzIcols0OPjjcf
1tHM2VGNVJ+6MpyN+KRsoIvfCCwnSKTh5m1DlWC/aLcCgJwTo3FbyK0WaBywErl9
FthIRpYQOUo3c93MZyJzsvSywXCRgzujpvcetMqFP9XVWPLDJRdfxZ7owkDVsGwN
r2xRegCCLWZIXlQpNsX6yJ67b8YkMJ5o2+62qW71N0CRDI/LVfNMST9K7W3/7OPR
oJ/VE9PreIPeJiFsQuRDW4X4RvoRxr9m8hLb5FkVnteyVmvaMTObSKKrGK3ZeJoa
B8g7q9rCyMcQmA9PPJA5
=5k0P
-----END PGP SIGNATURE-----

--Signature=_Thu__6_Jun_2013_12_04_55_+1000_4uFTmUaO3h/okSgd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
