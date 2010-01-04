Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E0B8D600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 07:39:03 -0500 (EST)
Received: by ey-out-1920.google.com with SMTP id 26so4484281eyw.6
        for <linux-mm@kvack.org>; Mon, 04 Jan 2010 04:39:01 -0800 (PST)
Date: Mon, 4 Jan 2010 12:38:58 +0000
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH] mm: move sys_mmap_pgoff from util.c
Message-ID: <20100104123858.GA5045@us.ibm.com>
References: <alpine.LSU.2.00.0912302009040.30390@sister.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0912302009040.30390@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 30 Dec 2009, Hugh Dickins wrote:

> Move sys_mmap_pgoff() from mm/util.c to mm/mmap.c and mm/nommu.c,
> where we'd expect to find such code: especially now that it contains
> the MAP_HUGETLB handling.  Revert mm/util.c to how it was in 2.6.32.
>=20
> This patch just ignores MAP_HUGETLB in the nommu case, as in 2.6.32,
> whereas 2.6.33-rc2 reported -ENOSYS.  Perhaps validate_mmap_request()
> should reject it with -EINVAL?  Add that later if necessary.
>=20
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

I think that -ENOSYS is the correcet response in the nommu case, but
I that can be added in a later patch.

Acked-by: Eric B Munson <ebmunson@us.ibm.com>

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAktB4WIACgkQsnv9E83jkzrx6gCfVC8k0PisgYMmLXl7JWGdiZfc
SnMAoIOoLNpwp9IzaEWBZErmlyO4gwL/
=t3b1
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
