From: Thomas Schlichter <thomas.schlichter@web.de>
Subject: Re: 2.6.1-mm3
Date: Wed, 14 Jan 2004 20:12:11 +0100
References: <20040114014846.78e1a31b.akpm@osdl.org>
In-Reply-To: <20040114014846.78e1a31b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-03=_LSZBAxZen3YomyA";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200401142012.11502.thomas.schlichter@web.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Russell King <rmk+lkml@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-03=_LSZBAxZen3YomyA
Content-Type: multipart/mixed;
  boundary="Boundary-01=_LSZBA4sEKkjGIfg"
Content-Transfer-Encoding: 7bit
Content-Description: signed data
Content-Disposition: inline

--Boundary-01=_LSZBA4sEKkjGIfg
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Description: body text
Content-Disposition: inline

Hi,

the patch "serial-02-fixups.patch" introduced following compile error:

  CC [M]  drivers/char/sx.o
drivers/char/sx.c: In function `sx_tiocmset':
drivers/char/sx.c:1761: error: `dtr' undeclared (first use in this function)
drivers/char/sx.c:1761: error: (Each undeclared identifier is reported only=
=20
once
drivers/char/sx.c:1761: error: for each function it appears in.)
drivers/char/sx.c:1756: Warnung: unused variable `cts'

The attached patch fixes it...

   Thomas Schlichter

--Boundary-01=_LSZBA4sEKkjGIfg
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="fix_sx.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="fix_sx.diff"

=2D-- linux-2.6.1-mm3/drivers/char/sx.c.orig	2004-01-14 19:33:13.367641928 =
+0100
+++ linux-2.6.1-mm3/drivers/char/sx.c	2004-01-14 19:35:06.915380048 +0100
@@ -1753,7 +1753,7 @@
 		       unsigned int set, unsigned int clear)
 {
 	struct sx_port *port =3D tty->driver_data;
=2D	int rts =3D -1, cts =3D -1;
+	int rts =3D -1, dtr =3D -1;
=20
 	if (set & TIOCM_RTS)
 		rts =3D 1;

--Boundary-01=_LSZBA4sEKkjGIfg--

--Boundary-03=_LSZBAxZen3YomyA
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQBABZSLYAiN+WRIZzQRAkd+AJ4lxVZpTOIX51TM2LEuwwbcsDk/0wCfYgF4
dvd+Ne3viYkF7jSL1mI+s1w=
=WwN/
-----END PGP SIGNATURE-----

--Boundary-03=_LSZBAxZen3YomyA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
