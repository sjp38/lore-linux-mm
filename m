From: Thomas Schlichter <thomas.schlichter@web.de>
Subject: Re: 2.6.1-mm4
Date: Fri, 16 Jan 2004 18:37:49 +0100
References: <20040115225948.6b994a48.akpm@osdl.org>
In-Reply-To: <20040115225948.6b994a48.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-03=_tFCCASc+11IE48h";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200401161837.49588.thomas.schlichter@web.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-03=_tFCCASc+11IE48h
Content-Type: multipart/mixed;
  boundary="Boundary-01=_tFCCAI4XgdaVBCn"
Content-Transfer-Encoding: 7bit
Content-Description: signed data
Content-Disposition: inline

--Boundary-01=_tFCCAI4XgdaVBCn
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Description: body text
Content-Disposition: inline

Hi,

the patch "PP4-bwqcam-RC1" includes a small typo which leads to the undefin=
ed=20
symbol 'strcnmp'. The attaches patch corrects this typo.

Best regards
   Thomas Schlichter

--Boundary-01=_tFCCAI4XgdaVBCn
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="fix-bw-qcam-typo.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="fix-bw-qcam-typo.diff"

=2D-- linux-2.6.1-mm4/drivers/media/video/bw-qcam.c.orig	2004-01-16 16:42:2=
7.178216712 +0100
+++ linux-2.6.1-mm4/drivers/media/video/bw-qcam.c	2004-01-16 16:42:51.53451=
3992 +0100
@@ -963,7 +963,7 @@
 #ifdef MODULE
 	int n;
=20
=2D	if (parport[0] && strcnmp(parport[0], "auto", 4) !=3D 0) {
+	if (parport[0] && strncmp(parport[0], "auto", 4) !=3D 0) {
 		/* user gave parport parameters */
 		for(n=3D0; parport[n] && n<MAX_CAMS; n++){
 			char *ep;

--Boundary-01=_tFCCAI4XgdaVBCn--

--Boundary-03=_tFCCASc+11IE48h
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQBACCFtYAiN+WRIZzQRAhlMAKDCYVnvjiIUUB+yCZ8fb/8WCLtO+QCfUt/z
YtH7AzN494z3jyQxA9mbDYM=
=OdBD
-----END PGP SIGNATURE-----

--Boundary-03=_tFCCASc+11IE48h--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
