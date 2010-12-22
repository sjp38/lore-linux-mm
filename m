Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 090816B0087
	for <linux-mm@kvack.org>; Tue, 21 Dec 2010 20:07:33 -0500 (EST)
Subject: Re: mmotm 2010-12-16 - breaks mlockall() call
In-Reply-To: Your message of "Mon, 20 Dec 2010 22:26:29 PST."
             <20101221062629.GA17066@google.com>
From: Valdis.Kletnieks@vt.edu
References: <201012162329.oBGNTdPY006808@imap1.linux-foundation.org> <131961.1292667059@localhost>
            <20101221062629.GA17066@google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1292980045_5103P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Dec 2010 20:07:25 -0500
Message-ID: <22255.1292980045@localhost>
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1292980045_5103P
Content-Type: text/plain; charset=us-ascii

On Mon, 20 Dec 2010 22:26:29 PST, Michel Lespinasse said:

> So the trivial fix to make mlockall behave identically as before could be
> as follows:
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index db0ed84..168b750 100644

Confirming this makes the mlockall() call in my initramfs behave as before...
Feel free to stick in a:

Tested-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

--==_Exmh_1292980045_5103P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNEU9NcC3lWbTT17ARAukQAJ0SzRwSTEHrlkx0IFGT/XdMs/DjkgCgyQKE
+aNo7wfO+CAaBWGZxFtxhBI=
=SPg9
-----END PGP SIGNATURE-----

--==_Exmh_1292980045_5103P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
