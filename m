Received: by ug-out-1314.google.com with SMTP id p35so464625ugc.19
        for <linux-mm@kvack.org>; Wed, 08 Oct 2008 02:34:21 -0700 (PDT)
Date: Wed, 8 Oct 2008 12:35:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
Message-ID: <20081008093526.GA4986@localhost.localdomain>
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name> <517f3f820810080157j3994ff10j8518178af02e5b22@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pWyiEgJYm5f9v55/"
Content-Disposition: inline
In-Reply-To: <517f3f820810080157j3994ff10j8518178af02e5b22@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 08, 2008 at 10:57:21AM +0200, Michael Kerrisk wrote:
> Kirill,
>=20
> On Tue, Oct 7, 2008 at 6:15 PM, Kirill A. Shutemov <kirill@shutemov.name>=
 wrote:
> > If SHM_MAP_NOT_FIXED specified and shmaddr is not NULL, then the kernel=
 takes
> > shmaddr as a hint about where to place the mapping. The address of the =
mapping
> > is returned as the result of the call.
> >
> > It's similar to mmap() without MAP_FIXED.
>=20
> Please CC linux-api@vger.kernel.org on patches that change the
> kernel-userspace interface.

Ok, I will.

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--pWyiEgJYm5f9v55/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjsft4ACgkQbWYnhzC5v6ojnACaA+yTJZGysNqJF+gPGEsWJJwR
FU4AniTGA7SoT/IUJoim7mXpb0xHICly
=x+Pb
-----END PGP SIGNATURE-----

--pWyiEgJYm5f9v55/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
