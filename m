Subject: 2.5.74-mm2 + nvidia (and others)
From: Christian Axelsson <smiler@lanil.mine.nu>
Reply-To: smiler@lanil.mine.nu
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-VEN7Ie1toC77uQhxjRzf"
Message-Id: <1057590519.12447.6.camel@sm-wks1.lan.irkk.nu>
Mime-Version: 1.0
Date: 07 Jul 2003 17:08:39 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-VEN7Ie1toC77uQhxjRzf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Ok, running fine with 2.5.74-mm2 but when I try to insert the nvidia
module (with patches from www.minion.de applied) it gives=20

nvidia: Unknown symbol pmd_offset

in dmesg. The vmware vmmon module gives the same error (the others wont
compile but thats a different story).

The nvidia module works fine under plain 2.5.74.

--=20
Christian Axelsson
smiler@lanil.mine.nu

--=-VEN7Ie1toC77uQhxjRzf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA/CYzeyqbmAWw8VdkRAoiIAJ9C/PpUYLN0bCLCESykEUUyvUIL4ACghIms
33tbCFy/6YtWNFlnGL0a5TU=
=f1Ck
-----END PGP SIGNATURE-----

--=-VEN7Ie1toC77uQhxjRzf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
