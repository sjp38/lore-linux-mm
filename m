Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 054379000BD
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 19:56:54 -0400 (EDT)
Subject: Re: [PATCH] staging: zcache: fix cleancache crash
In-Reply-To: Your message of "Tue, 13 Sep 2011 14:19:22 CDT."
             <1315941562-25422-1-git-send-email-sjenning@linux.vnet.ibm.com>
From: Valdis.Kletnieks@vt.edu
References: <4E6FA75A.8060308@linux.vnet.ibm.com>
            <1315941562-25422-1-git-send-email-sjenning@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1316131006_4167P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Sep 2011 19:56:46 -0400
Message-ID: <23267.1316131006@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: gregkh@suse.de, devel@driverdev.osuosl.org, linux-mm@kvack.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, francis.moro@gmail.com, dan.magenheimer@oracle.com

--==_Exmh_1316131006_4167P
Content-Type: text/plain; charset=us-ascii

On Tue, 13 Sep 2011 14:19:22 CDT, Seth Jennings said:
> After commit, c5f5c4db, cleancache crashes on the first
> successful get. This was caused by a remaining virt_to_page()
> call in zcache_pampd_get_data_and_free() that only gets
> run in the cleancache path.
> 
> The patch converts the virt_to_page() to struct page
> casting like was done for other instances in c5f5c4db.
> 
> Based on 3.1-rc4
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

I was seeing all sorts of bizzare memory corruptions and panics
and crashes while testing zcache - average uptime was only 2-3 hours.
With this patch applied, now have close to 24 hours of crash-free operation.
Feel free to add this if it isn't in somebody's tree already:

Tested-By: Valdis Kletnieks <valdis.kletnieks@vt.edu>

--==_Exmh_1316131006_4167P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOcpC+cC3lWbTT17ARArIUAJ4qEl1NZKDoZb0qr2LrbkJXqAo3cwCgiEir
4nFzV83wIlYhsv5Se2xEdzI=
=GZc5
-----END PGP SIGNATURE-----

--==_Exmh_1316131006_4167P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
