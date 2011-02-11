Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 891108D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 16:52:40 -0500 (EST)
Subject: Re: mmotm 2011-02-10-16-26 uploaded
In-Reply-To: Your message of "Thu, 10 Feb 2011 16:26:36 PST."
             <201102110100.p1B10sDx029244@imap1.linux-foundation.org>
From: Valdis.Kletnieks@vt.edu
References: <201102110100.p1B10sDx029244@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1297461155_5044P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 11 Feb 2011 16:52:35 -0500
Message-ID: <53491.1297461155@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--==_Exmh_1297461155_5044P
Content-Type: text/plain; charset=us-ascii

On Thu, 10 Feb 2011 16:26:36 PST, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2011-02-10-16-26 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

CONFIG_ZCACHE=m dies a horrid death:

  MODPOST 257 modules
ERROR: "xv_malloc" [drivers/staging/zcache/zcache.ko] undefined!
ERROR: "tmem_new_pool" [drivers/staging/zcache/zcache.ko] undefined!
ERROR: "tmem_put" [drivers/staging/zcache/zcache.ko] undefined!
ERROR: "tmem_destroy_pool" [drivers/staging/zcache/zcache.ko] undefined!
ERROR: "xv_free" [drivers/staging/zcache/zcache.ko] undefined!
ERROR: "xv_get_object_size" [drivers/staging/zcache/zcache.ko] undefined!
ERROR: "tmem_get" [drivers/staging/zcache/zcache.ko] undefined!
ERROR: "tmem_flush_object" [drivers/staging/zcache/zcache.ko] undefined!
ERROR: "tmem_flush_page" [drivers/staging/zcache/zcache.ko] undefined!
make[1]: *** [__modpost] Error 1

Looks like none of those have EXPORT_SYMBOL on them.


--==_Exmh_1297461155_5044P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNVa+jcC3lWbTT17ARAqUeAJ9PLoPrw+ZOUe8hL90Xa3ZfHnkNuQCfbkQP
kdW3CG+FiiGg8FrWeZC8tfU=
=QNea
-----END PGP SIGNATURE-----

--==_Exmh_1297461155_5044P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
