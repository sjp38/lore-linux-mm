From: Thomas Schlichter <schlicht@uni-mannheim.de>
Subject: Re: [2.5.70-mm8] NETDEV WATCHDOG: eth0: transmit timed out
Date: Wed, 11 Jun 2003 17:25:43 +0200
References: <20030611013325.355a6184.akpm@digeo.com> <200306111356.52950.schlicht@uni-mannheim.de> <200306111516.46648.schlicht@uni-mannheim.de>
In-Reply-To: <200306111516.46648.schlicht@uni-mannheim.de>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_9n05+GWjhokhT2/";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200306111725.49952.schlicht@uni-mannheim.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-02=_9n05+GWjhokhT2/
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

OK, I've found it...!

After reverting the pci-init-ordering-fix everything works as expected=20
again...

Best regards
  Thomas Schlichter

--Boundary-02=_9n05+GWjhokhT2/
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQA+50n9YAiN+WRIZzQRAg7iAJ4syPiKM3Omz5CmGvL5aQbLDp6lCACdHQg4
utVGid6mCLl9a9JL61f7t5c=
=ThDB
-----END PGP SIGNATURE-----

--Boundary-02=_9n05+GWjhokhT2/--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
