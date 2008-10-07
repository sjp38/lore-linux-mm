Received: by nf-out-0910.google.com with SMTP id c10so1590680nfd.6
        for <linux-mm@kvack.org>; Tue, 07 Oct 2008 04:20:52 -0700 (PDT)
Date: Tue, 7 Oct 2008 14:21:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC] shmat: introduce flag SHM_MAP_HINT
Message-ID: <20081007112157.GA5126@localhost.localdomain>
References: <20081006132651.GG3180@one.firstfloor.org> <1223303879-5555-1-git-send-email-kirill@shutemov.name> <20081007195837.5A6B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081007112119.GG20740@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
In-Reply-To: <20081007112119.GG20740@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 07, 2008 at 01:21:19PM +0200, Andi Kleen wrote:
> > Honestly, I don't like that qemu specific feature insert into shmem cor=
e.
>=20
> I wouldn't say it's a qemu specific interface.  While qemu would=20
> be the first user I would expect more in the future. It's a pretty
> obvious extension. In fact it nearly should be default, if the
> risk of breaking old applications wasn't too high.

It's bad idea. It will break POSIX compatible.

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjrRlUACgkQbWYnhzC5v6o9ZQCfdXw0/6+rOfTVNOdznzH0YGg6
2j0An1LTSY9Db6LJchJe2avOxbzuFcSH
=BigC
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
