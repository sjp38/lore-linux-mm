Subject: Re: 2.5.74-mm2 + nvidia (and others)
From: Christian Axelsson <smiler@lanil.mine.nu>
Reply-To: smiler@lanil.mine.nu
In-Reply-To: <200307071734.01575.schlicht@uni-mannheim.de>
References: <1057590519.12447.6.camel@sm-wks1.lan.irkk.nu>
	 <200307071734.01575.schlicht@uni-mannheim.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-holf9TlXk8wASZ0OCRgY"
Message-Id: <1057597773.6857.1.camel@sm-wks1.lan.irkk.nu>
Mime-Version: 1.0
Date: 07 Jul 2003 19:09:33 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-holf9TlXk8wASZ0OCRgY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2003-07-07 at 17:33, Thomas Schlichter wrote:
> The problem is the highpmd patch in -mm2. There are two options:
> 1. Revert the highpmd patch.
> 2. Apply the attached patch to the NVIDIA kernel module sources.

Thanks alot, applying the patch you supplied cured the problem.

--=20
Christian Axelsson
smiler@lanil.mine.nu

--=-holf9TlXk8wASZ0OCRgY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA/CalNyqbmAWw8VdkRAoVnAJ9MS76dMjIi65suY8htmHFfdQUCDwCg3Hp9
fg/uAwzD4lY7PkEVEUOrdDg=
=6DVm
-----END PGP SIGNATURE-----

--=-holf9TlXk8wASZ0OCRgY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
