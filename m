From: Thomas Schlichter <thomas.schlichter@web.de>
Subject: Re: 2.6.1-mm3
Date: Wed, 14 Jan 2004 20:11:56 +0100
References: <20040114014846.78e1a31b.akpm@osdl.org>
In-Reply-To: <20040114014846.78e1a31b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-03=_9RZBAE5ZBJIzsEE";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200401142011.57021.thomas.schlichter@web.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Russell King <rmk+lkml@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-03=_9RZBAE5ZBJIzsEE
Content-Type: multipart/mixed;
  boundary="Boundary-01=_8RZBA4TvFEW4mG9"
Content-Transfer-Encoding: 7bit
Content-Description: signed data
Content-Disposition: inline

--Boundary-01=_8RZBA4TvFEW4mG9
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Description: body text
Content-Disposition: inline

Hi,

the patch "serial-02-fixups.patch" introduced following compile error:

  CC [M]  drivers/char/cyclades.o
drivers/char/cyclades.c: In function `cy_tiocmset':
drivers/char/cyclades.c:3719: error: `value' undeclared (first use in this=
=20
function)
drivers/char/cyclades.c:3719: error: (Each undeclared identifier is reporte=
d=20
only once
drivers/char/cyclades.c:3719: error: for each function it appears in.)
drivers/char/cyclades.c:3719: Warnung: unused variable `arg'

The attached patch fixes it...

   Thomas Schlichter

--Boundary-01=_8RZBA4TvFEW4mG9
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="fix_cyclades.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="fix_cyclades.diff"

--- linux-2.6.1-mm3/drivers/char/cyclades.c.orig	2004-01-14 18:54:24.716650688 +0100
+++ linux-2.6.1-mm3/drivers/char/cyclades.c	2004-01-14 18:54:30.076835816 +0100
@@ -3716,7 +3716,6 @@
   int card,chip,channel,index;
   unsigned char *base_addr;
   unsigned long flags;
-  unsigned int arg = cy_get_user((unsigned long *) value);
   struct FIRM_ID *firm_id;
   struct ZFW_CTRL *zfw_ctrl;
   struct BOARD_CTRL *board_ctrl;

--Boundary-01=_8RZBA4TvFEW4mG9--

--Boundary-03=_9RZBAE5ZBJIzsEE
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQBABZR9YAiN+WRIZzQRAsjeAJwNctj/xhp8BUMiFMcbvbQHc7wOgQCgo5uZ
GL7LLIZ5PvaTgHoNa9tAzf4=
=0QM/
-----END PGP SIGNATURE-----

--Boundary-03=_9RZBAE5ZBJIzsEE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
