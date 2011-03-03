Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 184808D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 21:31:07 -0500 (EST)
Date: Thu, 3 Mar 2011 13:30:55 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2011-03-02-16-52 uploaded
Message-Id: <20110303133055.db60038b.sfr@canb.auug.org.au>
In-Reply-To: <20110302181711.2399cdba.akpm@linux-foundation.org>
References: <201103030127.p231ReNl012841@imap1.linux-foundation.org>
	<20110303130538.3e99f952.sfr@canb.auug.org.au>
	<20110302181711.2399cdba.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__3_Mar_2011_13_30_55_+1100_l8HoQFifYTbNevkY"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--Signature=_Thu__3_Mar_2011_13_30_55_+1100_l8HoQFifYTbNevkY
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, 2 Mar 2011 18:17:11 -0800 Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>
> What's in the 8000 lines?

Just the localversion-next file and the stuff in the "Next" directory ...
meta information about the linux-next tree.

> Didn't understand that - why is git-am unhappy?  Your sentence was
> truncated.

It didn't recognise the patch format since it wants an email-like patch
(with a From line to show the author).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__3_Mar_2011_13_30_55_+1100_l8HoQFifYTbNevkY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNbv1fAAoJEDMEi1NhKgbsR2kH/0prVyROTO7hUdnJ5mv1CcPJ
A4WrZOAaIvZIWkcjaVPtVmkWihGnx0e0jLEb8kSR9kyNUjHXkY4LbHvkAnLChwxb
ZoREL61FSg1H5M3lu7P79yI+MNhgie8X/eSBvapXm47kE9Aox9VbueTv1fN38abg
grvr/K5aA2SVvm1gsS8pAdbHONHF+RHj08i1wsAWZtdpjUNkq4B/OZGYQpGx8PBh
DLohDcNkuStZcY2C366Pe6fBv70GVIE4cR7qW0KNtwx/tYUYXzFQHq/YtQMYX5mO
cLD4drg2LSEZ1ItgkQ+i22bnFRN5/C5UdRg3DFjxlSUp8HLm1YvcSZjGE/vczNs=
=kPZM
-----END PGP SIGNATURE-----

--Signature=_Thu__3_Mar_2011_13_30_55_+1100_l8HoQFifYTbNevkY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
