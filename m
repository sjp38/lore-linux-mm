Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C2E5D6B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 19:58:04 -0400 (EDT)
Date: Tue, 16 Apr 2013 09:57:53 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 5/5] mm: Soft-dirty bits for user memory changes
 tracking
Message-Id: <20130416095753.d94fa7d74db6c4293ec7dea9@canb.auug.org.au>
In-Reply-To: <20130415144619.645394d8ecdb180d7757a735@linux-foundation.org>
References: <51669E5F.4000801@parallels.com>
	<51669EB8.2020102@parallels.com>
	<20130411142417.bb58d519b860d06ab84333c2@linux-foundation.org>
	<5168089B.7060305@parallels.com>
	<20130415144619.645394d8ecdb180d7757a735@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__16_Apr_2013_09_57_53_+1000_DzV3xC3VcGJY8=O2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--Signature=_Tue__16_Apr_2013_09_57_53_+1000_DzV3xC3VcGJY8=O2
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 15 Apr 2013 14:46:19 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> Well, this is also a thing arch maintainers can do when they feel a
> need to support the feature on their architecture.  To support them at
> that time we should provide them with a) adequate information in an
> easy-to-find place (eg, a nice comment at the site of the reference x86
> implementation) and b) a userspace test app.

and c) a CONFIG symbol (maybe CONFIG_HAVE_MEM_SOFT_DIRTY, maybe in
arch/Kconfig) that they can select to get this feature (so that this
feature then depend on that CONFIG symbol instead of X86).  That way we
don't have to go back and tidy this up when 15 or so architectures
implement it.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__16_Apr_2013_09_57_53_+1000_DzV3xC3VcGJY8=O2
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRbJQBAAoJEECxmPOUX5FE0vcP/iSlzGF4U0CKadJ9YMkW9x7w
Yi9cA4ra6t6NS+NTdhRVJZl5ZjzBMSjGj01UeGbVkSjYzGVKpFCtk7FMthYqo+ky
1iCZVtsGymU7OeJpNho3s8K+q4G5DH+4kV6S00vGJdCZxANUlLqJ8ZEeHwrxSlMS
YdcRcLdQsVE5bzBflBnNOv4Zye9+z1QiXo3n0nEdpZY1IcfgRqsE0f2nX3DrhLz5
ZlxS+4LtXaDA7QGgk/SOxNGTAU9Q5dKDpCbcVAwheoyl+A+g7AEaCZKKMN1Fsouh
xPUOwr6CM3brkmSBjXVFrZv263Tx1i1dScrzz4dmQQ3tWcRFbLvBQwc+me4A5EYA
Ik6qYqkfqeEJ8EKRjQzA3FT3oWFuFQM4xbOQ9qDwJF/l9Z4jHVzLUuRkbqNcSvgN
UBdgkV0QbIqFaFTvIYjgBpM0qBsKD3igLoS5zEo531k01ybKxxYfu2tm09nGfg9e
AExjuB5/dTTmtQBy26SS2A458oSmCqhHNuuWkry38RubXtx1vFTjHnQbbo7HhLNY
mQ84ocWmsR6WctLTNxpIXXVRmQ8mocLIxQlPgxgLw/ozeW+YW5CZeW359WfgUVBR
qpcYrs3zPaIVp+MS2/pQ/eMMEeM+GVc/+pLjoJM6YkDA6y8/CVndSmYaiD7Nvl17
V9LPhgi0ZQpx8S9wxNKJ
=d5Gx
-----END PGP SIGNATURE-----

--Signature=_Tue__16_Apr_2013_09_57_53_+1000_DzV3xC3VcGJY8=O2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
