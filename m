From: Thomas Schlichter <thomas.schlichter@web.de>
Subject: Re: 2.6.1-mm4
Date: Fri, 16 Jan 2004 18:58:15 +0100
References: <20040115225948.6b994a48.akpm@osdl.org>
In-Reply-To: <20040115225948.6b994a48.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-03=_3YCCA+zehlKsYVM";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200401161858.15325.thomas.schlichter@web.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-03=_3YCCA+zehlKsYVM
Content-Type: multipart/mixed;
  boundary="Boundary-01=_3YCCA0kq8snzRZa"
Content-Transfer-Encoding: 7bit
Content-Description: signed data
Content-Disposition: inline

--Boundary-01=_3YCCA0kq8snzRZa
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Description: body text
Content-Disposition: inline

Hi Andrew,

the attached patch fixes a link error of the kernel module 'drivers/scsi/
pcmcia/aha152x_cs.ko' because of two module_init() and two module_exit()=20
functions. Now the module links but I did not test it further...

Best regards
   Thomas Schlichter

--Boundary-01=_3YCCA0kq8snzRZa
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="fix-PCMCIA-aha152x.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="fix-PCMCIA-aha152x.diff"

=2D-- linux-2.6.1-mm4/drivers/scsi/aha152x.c.orig	2004-01-16 16:26:09.01891=
9528 +0100
+++ linux-2.6.1-mm4/drivers/scsi/aha152x.c	2004-01-16 16:26:42.661805032 +0=
100
@@ -3914,5 +3914,7 @@
 	.use_clustering			=3D DISABLE_CLUSTERING,
 };
=20
+#if !defined(PCMCIA)
 module_init(aha152x_init);
 module_exit(aha152x_exit);
+#endif

--Boundary-01=_3YCCA0kq8snzRZa--

--Boundary-03=_3YCCA+zehlKsYVM
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQBACCY3YAiN+WRIZzQRAlfZAKCcuN+ynR+T6OohW10EwRa6RIRUHwCcDWaM
80QvtfBEuZeoCteV/lJubtU=
=MFb+
-----END PGP SIGNATURE-----

--Boundary-03=_3YCCA+zehlKsYVM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
