Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 2C6CE8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 16:02:23 -0400 (EDT)
Date: Fri, 11 May 2012 23:02:13 +0300
From: Sami Liedes <sami.liedes@iki.fi>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process wcg_gfam_6.11_i
Message-ID: <20120511200213.GB7387@sli.dy.fi>
References: <bug-43227-27@https.bugzilla.kernel.org/>
 <20120511125921.a888e12c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="9zSXsLTf0vkW971A"
Content-Disposition: inline
In-Reply-To: <20120511125921.a888e12c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org


--9zSXsLTf0vkW971A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 11, 2012 at 12:59:21PM -0700, Andrew Morton wrote:
> > [67031.755786] BUG: Bad page state in process wcg_gfam_6.11_i  pfn:02519
> > [67031.755790] page:ffffea0000094640 count:0 mapcount:0 mapping:       =
 =20
> > (null) index:0x7f1eb293b
> > [67031.755792] page flags: 0x4000000000000014(referenced|dirty)
>=20
> AFAICT we got this warning because the page allocator found a free page
> with PG_referenced and PG_dirty set.
>=20
> It would be a heck of a lot more useful if we'd been told about this
> when the page was freed, not when it was reused!  Can anyone think of a
> reason why PAGE_FLAGS_CHECK_AT_FREE doesn't include these flags (at
> least)?

Would it be useful if I tried to reproduce this with some debugging
options turned on, for example CONFIG_DEBUG_VM?

	Sami

--9zSXsLTf0vkW971A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCgAGBQJPrXBFAAoJEKLT589SE0a0gUUP/1hLPwYQjZ+xzFV6iKB12Eik
ejSBxALOsKL68q4JG39qOAE0RL0TWxXsQPHchARF7z9TG/D6fTKZT/Gpw7IN2vZB
kIipwjkJ6RbXGdnCWNLpG98qNePQah1ZZAFV8KYyPTF1gsaHk/YoMgSmwrtkUt1i
Ccv93G60Nu/8CjYKyWF+s+JkPATxFxw8tBKaNe6d8DJoHCjwSR+pvW1JIIbgqtW6
nFT69L+9QmNy+62ajDKAD2ogZulxsaEGq3vDQ6WZIRfzL4PZXzX8G/jN9rzc+WFp
KCsNgRS5jiAaHUP5J13d5qmSv+T6ZmfWA5GZYDwDVyZ+nJiIBL8z0UbLVXUW6QGX
cg15QHLiYtY2KI4tmtKsZ3QwAJbvkewRRxPajybicnW4KHbcU2zSC4U7r+d2zHt+
BZmWT1fHOeRbclVTvhh8Kbrs/YWQNvOsmuDnQL+awsxcnreGK5pmNJg96eTfCqUe
rizgjQWwEHpxbETVB4vMyY0LjpU0hNqa5q2WfqLhJkZiulEBTPiq36L9g7KpZ/Je
CJjAvADZdReOuTHFzvBDdoJvXEHCY2FqLN/nWKkrO19tI8iT1ONi39upPjHuZADF
V/PGEOcGmv5FfAsAefw/HQKf6dtzlJQp7oUaAQEDO99WH2ryZvAdFUSqi1Gg7zLU
vw5jgeK3gV1YjMnp6Jyz
=4Qxu
-----END PGP SIGNATURE-----

--9zSXsLTf0vkW971A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
