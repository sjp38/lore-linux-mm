Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id EF3ED6B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 15:05:43 -0500 (EST)
Subject: Re: [PATCH V2 1/6] drivers/staging/ramster: cluster/messaging foundation
In-Reply-To: Your message of "Thu, 22 Dec 2011 07:50:50 PST."
             <20111222155050.GA21405@ca-server1.us.oracle.com>
From: Valdis.Kletnieks@vt.edu
References: <20111222155050.GA21405@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1325016332_3579P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 27 Dec 2011 15:05:32 -0500
Message-ID: <243729.1325016332@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: greg@kroah.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, kurt.hackel@oracle.com, sjenning@linux.vnet.ibm.com, chris.mason@oracle.com

--==_Exmh_1325016332_3579P
Content-Type: text/plain; charset=us-ascii

On Thu, 22 Dec 2011 07:50:50 PST, Dan Magenheimer said:

> Copy cluster subdirectory from ocfs2.  These files implement
> the basic cluster discovery, mapping, heartbeat / keepalive, and
> messaging ("o2net") that ramster requires for internode communication.

Instead of doing this, can we have the shared files copied to a common
subdirectory so that ramster and ocfs2 can share them, and we only
have to fix bugs once?

--==_Exmh_1325016332_3579P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFO+iUMcC3lWbTT17ARAmGfAKCENDjN79TxO+C7OZ06guBX0h6vowCgusxg
htspX2q/+e756QN70cO8BEg=
=d18g
-----END PGP SIGNATURE-----

--==_Exmh_1325016332_3579P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
