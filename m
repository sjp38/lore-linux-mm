Message-Id: <200307021827.h62IRCp3001341@turing-police.cc.vt.edu>
Subject: Re: 2.5.73-mm3 
In-Reply-To: Your message of "Tue, 01 Jul 2003 20:38:30 PDT."
             <20030701203830.19ba9328.akpm@digeo.com>
From: Valdis.Kletnieks@vt.edu
References: <20030701203830.19ba9328.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-1586579328P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 02 Jul 2003 14:27:12 -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_-1586579328P
Content-Type: text/plain; charset=us-ascii

On Tue, 01 Jul 2003 20:38:30 PDT, Andrew Morton <akpm@digeo.com>  said:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.73/2.5.73-mm3/

> . The weird behaviour with time-n-date on SpeedStep machines should be
>   fixed.  Some of the weird behaviour, at least.

The problem I noted with speedstep-ich.c mangling the loops_per_jiffies variable
is still there.  Looks like I have something to do on the plane tomorrow. ;)

--==_Exmh_-1586579328P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQE/AyQAcC3lWbTT17ARAglgAJwOL6q4f3d1kactDN3RMgNG+/tZjgCcCuVX
wV8bHEEyPDh1eLWHftdIDzE=
=nzKV
-----END PGP SIGNATURE-----

--==_Exmh_-1586579328P--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
