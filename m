Subject: Re: [BUG] Re: 2.6.0-test8-mm1
From: =?ISO-8859-1?Q?Ram=F3n?= Rey Vicente <ramon.rey@hispalinux.es>
In-Reply-To: <20031020131008.19125b7c.akpm@osdl.org>
References: <20031020020558.16d2a776.akpm@osdl.org>
	 <1066677679.2121.3.camel@debian>  <20031020131008.19125b7c.akpm@osdl.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/2j7gD3SPDm3rv8+OAcD"
Message-Id: <1066686831.3629.2.camel@debian>
Mime-Version: 1.0
Date: Mon, 20 Oct 2003 23:53:52 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-/2j7gD3SPDm3rv8+OAcD
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

El lun, 20-10-2003 a las 22:10, Andrew Morton escribi=F3:
> Ram=F3n Rey Vicente <rrey@ranty.pantax.net> wrote:
> >
> > The same problem with other kernel versions. I get it trying to delete
> > my local 2.6 svn repository:
> >=20
> > EXT3-fs error (device hdb1): ext3_free_blocks: Freeing blocks in system
> > zones - Block =3D 512, count =3D 1
>=20
> This is consistent with a corrupted filesystem.  Have you forced a fsck
> against that partition?

Ups, yes, it seems the filesystem was corrupted/inconsistent but with a
fsck now all is OK. Sorry for this. :-X
--=20
Ram=F3n Rey Vicente       <ramon dot rey at hispalinux dot es>
        jabber ID       <rreylinux at jabber dot org>
GPG public key ID 	0xBEBD71D5 -> http://pgp.escomposlinux.org/

--=-/2j7gD3SPDm3rv8+OAcD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Esta parte del mensaje =?ISO-8859-1?Q?est=E1?= firmada
	digitalmente

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/lFlvRGk68b69cdURAk6dAJ9RU556OdgyKurha+ToKcy2st+1lACeL/Xm
FEU5NWreJgd/aFieh4eux5M=
=Hm+u
-----END PGP SIGNATURE-----

--=-/2j7gD3SPDm3rv8+OAcD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
