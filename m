Subject: Re: 2.5.74-mm2 + nvidia (and others)
From: Christian Axelsson <smiler@lanil.mine.nu>
Reply-To: smiler@lanil.mine.nu
In-Reply-To: <1057647818.5489.385.camel@workshop.saharacpt.lan>
References: <1057590519.12447.6.camel@sm-wks1.lan.irkk.nu>
	 <200307071734.01575.schlicht@uni-mannheim.de>
	 <20030707123012.47238055.akpm@osdl.org>
	 <1057647818.5489.385.camel@workshop.saharacpt.lan>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-KM9WHTbuPfZf5AM3Qmmw"
Message-Id: <1057664435.6854.14.camel@sm-wks1.lan.irkk.nu>
Mime-Version: 1.0
Date: 08 Jul 2003 13:40:35 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schlemmer <azarah@gentoo.org>
Cc: Andrew Morton <akpm@osdl.org>, Thomas Schlichter <schlicht@uni-mannheim.de>, KML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-KM9WHTbuPfZf5AM3Qmmw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2003-07-08 at 09:03, Martin Schlemmer wrote:
> On Mon, 2003-07-07 at 21:30, Andrew Morton wrote:
>=20
> > Well that will explode if someone enables highpmd and has highmem.
> > This would be better:
> >=20
> > --- nv.c.orig	2003-07-05 22:55:10.000000000 -0700
> > +++ nv.c	2003-07-05 22:55:58.000000000 -0700
> > @@ -2105,11 +2105,14 @@
> >      if (pgd_none(*pg_dir))
> >          goto failed;
> > =20
> > -    pg_mid_dir =3D pmd_offset(pg_dir, address);
> > -    if (pmd_none(*pg_mid_dir))
> > +    pg_mid_dir =3D pmd_offset_map(pg_dir, address);
> > +    if (pmd_none(*pg_mid_dir)) {
> > +	pmd_unmap(pg_mid_dir);
> >          goto failed;
> > +    }
> > =20
> >      NV_PTE_OFFSET(address, pg_mid_dir, pte);
> > +    pmd_unmap(pg_mid_dir);
> > =20
> >      if (!pte_present(pte))
> >          goto failed;
> >=20
> > -
>=20
> Bit too specific to -mm2, what about the the attached?

Compiles nicely, havent but I havent reloaded it yet.

--=20
Christian Axelsson
smiler@lanil.mine.nu

--=-KM9WHTbuPfZf5AM3Qmmw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA/Cq2xyqbmAWw8VdkRAvttAKCvQkQSvIQiZe8lbb0nsBEjgmUwygCgvufs
KbJCJ6o1xXGcauTZjx1VLSM=
=G6E7
-----END PGP SIGNATURE-----

--=-KM9WHTbuPfZf5AM3Qmmw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
