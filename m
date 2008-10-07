Received: by ug-out-1314.google.com with SMTP id p35so177868ugc.19
        for <linux-mm@kvack.org>; Tue, 07 Oct 2008 04:22:17 -0700 (PDT)
Date: Tue, 7 Oct 2008 14:23:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC, v2] shmat: introduce flag SHM_MAP_HINT
Message-ID: <20081007112322.GB5126@localhost.localdomain>
References: <20081006192923.GJ3180@one.firstfloor.org> <1223362670-5187-1-git-send-email-kirill@shutemov.name> <20081007082030.GD20740@one.firstfloor.org> <20081007100854.GA5039@localhost.localdomain> <20081007112631.GH20740@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="p4qYPpj5QlsIQJ0K"
Content-Disposition: inline
In-Reply-To: <20081007112631.GH20740@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--p4qYPpj5QlsIQJ0K
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 07, 2008 at 01:26:31PM +0200, Andi Kleen wrote:
> > I want say that we shouldn't do this check if shmaddr is a search hint.
> > I'm not sure that check is unneeded if shmadd is the exact address.
>=20
> mmap should fail in this case because it does the same check for=20
> MAP_FIXED. Obviously it cannot succeed when there is already something
> else there.

We can do it in separate patch, I think.

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--p4qYPpj5QlsIQJ0K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjrRqoACgkQbWYnhzC5v6q8ggCfXxRCGEVKzNzwBmGkgyXivVPf
8VIAn1GVBWH3QRPfIzEF3MIV5s1I1BOV
=mdMV
-----END PGP SIGNATURE-----

--p4qYPpj5QlsIQJ0K--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
