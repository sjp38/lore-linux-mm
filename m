Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1A646B02A3
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 10:42:58 -0400 (EDT)
Subject: Re: [PATCH 0/8] zcache: page cache compression support
In-Reply-To: Your message of "Fri, 23 Jul 2010 14:02:16 EDT."
             <1507379750.1116011279908136772.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
From: Valdis.Kletnieks@vt.edu
References: <1507379750.1116011279908136772.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1279982510_3953P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Sat, 24 Jul 2010 10:41:50 -0400
Message-ID: <93365.1279982510@localhost>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Nitin Gupta <ngupta@vflare.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1279982510_3953P
Content-Type: text/plain; charset=us-ascii

On Fri, 23 Jul 2010 14:02:16 EDT, CAI Qian said:
> Ignore me. The test case should not be using mlockall()!

I'm confused. I don't see any mlockall() call in the usemem.c you posted? Or
was what you posted not what you actually ran?


--==_Exmh_1279982510_3953P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFMSvuucC3lWbTT17ARAseaAJ4gxpD4bi6+Z3dxvD3HUlTZsmEf2wCeLeQ3
CUr9ficK5W80YcjwJPStvlQ=
=4r0W
-----END PGP SIGNATURE-----

--==_Exmh_1279982510_3953P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
