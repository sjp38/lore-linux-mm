From: Thomas Schlichter <schlicht@uni-mannheim.de>
Subject: Bug in 2.5.70-mm9: df: `/': Value too large for defined data type
Date: Fri, 13 Jun 2003 12:50:44 +0200
References: <20030613013337.1a6789d9.akpm@digeo.com>
In-Reply-To: <20030613013337.1a6789d9.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_Lya6+wzJtqH8mmO";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200306131250.51502.schlicht@uni-mannheim.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-02=_Lya6+wzJtqH8mmO
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi!

When I enter 'df' in my bash with -mm9 I get following:
  Filesystem           1k-blocks      Used Available Use% Mounted on
  df: `/': Value too large for defined data type
  /dev/hda3                 7776      5718      1657  78% /boot

instead of:
  Filesystem           1k-blocks      Used Available Use% Mounted on
  /dev/hda5              7421764   7296016    125748  99% /
  /dev/hda3                 7776      5718      1657  78% /boot

-mm8 worked without this problem.

Here is what 'mount' says:
  /dev/hda5 on / type reiserfs (rw)
  proc on /proc type proc (rw)
  devpts on /dev/pts type devpts (rw,mode=0620,gid=5)
  /sys on /sys type sysfs (rw)
  /dev/hda3 on /boot type ext3 (rw)

I use fileutils 4.1

Best regards
   Thomas Schlichter

--Boundary-02=_Lya6+wzJtqH8mmO
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQA+6ayLYAiN+WRIZzQRAn7KAJ455DN3cZP4d0+y2hBGhoyo3E+2UwCfQN7Q
j5k7n/YdKJlOT97hp5Iuuds=
=uWEC
-----END PGP SIGNATURE-----

--Boundary-02=_Lya6+wzJtqH8mmO--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
