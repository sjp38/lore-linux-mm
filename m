Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 95DE86B00EE
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:47:55 -0400 (EDT)
Subject: Re: [PATCH V8 4/4] mm: frontswap: config and doc files
In-Reply-To: Your message of "Mon, 29 Aug 2011 09:49:49 PDT."
             <20110829164949.GA27238@ca-server1.us.oracle.com>
From: Valdis.Kletnieks@vt.edu
References: <20110829164949.GA27238@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1314737185_2796P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Aug 2011 16:46:25 -0400
Message-ID: <19213.1314737185@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

--==_Exmh_1314737185_2796P
Content-Type: text/plain; charset=us-ascii

On Mon, 29 Aug 2011 09:49:49 PDT, Dan Magenheimer said:

> --- linux/mm/Kconfig	2011-08-08 08:19:26.303686905 -0600
> +++ frontswap/mm/Kconfig	2011-08-29 09:52:14.308745832 -0600
> @@ -370,3 +370,20 @@ config CLEANCACHE
>  	  in a negligible performance hit.
>  
>  	  If unsure, say Y to enable cleancache
> +
> +config FRONTSWAP
> +	bool "Enable frontswap to cache swap pages if tmem is present"
> +	depends on SWAP
> +	default n

> +
> +	  If unsure, say Y to enable frontswap.

Am I the only guy who gets irked when the "default" doesn't match the
"If unsure" suggestion?  :)  (and yes, I know we have guidelines for
what the "default" should be...)

--==_Exmh_1314737185_2796P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOXUwhcC3lWbTT17ARAidQAJ9dvc2aWheQ7QEVPHlD3c0vwHr6NQCgouUj
4nKyngyvWzkSZE2jPzCvAnc=
=Zt2l
-----END PGP SIGNATURE-----

--==_Exmh_1314737185_2796P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
