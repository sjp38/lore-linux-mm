Subject: Re: 2.6.3-rc1-mm1 (SELinux + ext3 + nfsd oops)
From: Chris PeBenito <pebenito@gentoo.org>
In-Reply-To: <Xine.LNX.4.44.0402102128210.9747-100000@thoron.boston.redhat.com>
References: <Xine.LNX.4.44.0402102128210.9747-100000@thoron.boston.redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Dvp8nMBgu1M5cWVFmjD7"
Message-Id: <1076471114.4925.0.camel@chris.pebenito.net>
Mime-Version: 1.0
Date: Tue, 10 Feb 2004 21:45:15 -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Morris <jmorris@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Stephen Smalley <sds@epoch.ncsc.mil>
List-ID: <linux-mm.kvack.org>

--=-Dvp8nMBgu1M5cWVFmjD7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Still oopses.  I also tried with 2.6.3-rc2, and it also oopses.

On Tue, 2004-02-10 at 20:29, James Morris wrote:
> On Tue, 10 Feb 2004, Chris PeBenito wrote:
>=20
> > I got an oops on boot when nfsd is starting up on a SELinux+ext3
> > machine.  It exports /home, which is mounted thusly:
> >=20
>=20
> What happens if you try this this patch:
>=20
> http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=3D107637246127197&w=3D2 =
?
>=20
>=20
>=20
> - James
--=20
Chris PeBenito
<pebenito@gentoo.org>
Developer,
Hardened Gentoo Linux
Embedded Gentoo Linux
=20
Public Key: http://pgp.mit.edu:11371/pks/lookup?op=3Dget&search=3D0xE6AF924=
3
Key fingerprint =3D B0E6 877A 883F A57A 8E6A  CB00 BC8E E42D E6AF 9243

--=-Dvp8nMBgu1M5cWVFmjD7
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAKaVKvI7kLeavkkMRAk+RAJ94V0FvfsP6h1ftrL2c6iIegNXIMwCdEIea
2ZGYQDOlXyGuKDvElAve9h4=
=9wRk
-----END PGP SIGNATURE-----

--=-Dvp8nMBgu1M5cWVFmjD7--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
