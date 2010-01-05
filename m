Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4CE1C6007BA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 07:47:21 -0500 (EST)
Received: by ewy24 with SMTP id 24so21610285ewy.6
        for <linux-mm@kvack.org>; Tue, 05 Jan 2010 04:47:18 -0800 (PST)
Date: Tue, 5 Jan 2010 12:47:14 +0000
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH] nommu: reject MAP_HUGETLB
Message-ID: <20100105124714.GA6620@us.ibm.com>
References: <alpine.LSU.2.00.0912302009040.30390@sister.anvils>
 <20100104123858.GA5045@us.ibm.com>
 <alpine.LSU.2.00.1001051232530.1055@sister.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AhhlLboLdkugWU4S"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1001051232530.1055@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 05 Jan 2010, Hugh Dickins wrote:

> We've agreed to restore the rejection of MAP_HUGETLB to nommu.
> Mimic what happens with mmu when hugetlb is not configured in:
> say -ENOSYS, but -EINVAL if MAP_ANONYMOUS was not given too.
>=20
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Eric B Munson <ebmunson@us.ibm.com>

--AhhlLboLdkugWU4S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAktDNNIACgkQsnv9E83jkzov9QCgpLESFDrJNrx/RpS+jZvj/F/8
gx4AoJDMHW02SXGFtMZFpOQphDDTO5mN
=avtv
-----END PGP SIGNATURE-----

--AhhlLboLdkugWU4S--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
