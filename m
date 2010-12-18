Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C4E266B009A
	for <linux-mm@kvack.org>; Sat, 18 Dec 2010 05:11:09 -0500 (EST)
Subject: mmotm 2010-12-16 - breaks mlockall() call
In-Reply-To: Your message of "Thu, 16 Dec 2010 14:56:39 PST."
             <201012162329.oBGNTdPY006808@imap1.linux-foundation.org>
From: Valdis.Kletnieks@vt.edu
References: <201012162329.oBGNTdPY006808@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1292667059_131643P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Sat, 18 Dec 2010 05:10:59 -0500
Message-ID: <131961.1292667059@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>
Cc: linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1292667059_131643P
Content-Type: text/plain; charset=us-ascii

On Thu, 16 Dec 2010 14:56:39 PST, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2010-12-16-14-56 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

The patch mlock-only-hold-mmap_sem-in-shared-mode-when-faulting-in-pages.patch
causes this chunk of code from cryptsetup-luks to fail during the initramfs:

	if (mlockall(MCL_CURRENT | MCL_FUTURE)) {
                        log_err(ctx, _("WARNING!!! Possibly insecure memory. Are you root?\n"));
                        _memlock_count--;
                        return 0;
                }

Bisection fingered this patch, which was added after -rc4-mmotm1202, which
boots without tripping this log_err() call.  I haven't tried building a
-rc6-mmotm1216 with this patch reverted, because reverting it causes apply
errors for subsequent patches.

Ideas?



--==_Exmh_1292667059_131643P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNDIizcC3lWbTT17ARAoqyAJwJgWcv6nVI2dPt5mjCr5CFhzwa8gCfcP0p
LtHJhxD89wxagNQco+pC6js=
=8EEn
-----END PGP SIGNATURE-----

--==_Exmh_1292667059_131643P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
