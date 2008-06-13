Subject: Re: [BUG] 2.6.26-rc5-mm3 kernel BUG at mm/filemap.c:575!
In-Reply-To: Your message of "Thu, 12 Jun 2008 14:14:21 +0530."
             <4850E1E5.90806@linux.vnet.ibm.com>
From: Valdis.Kletnieks@vt.edu
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
            <4850E1E5.90806@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1213330723_2983P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Jun 2008 00:18:43 -0400
Message-ID: <4041.1213330723@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1213330723_2983P
Content-Type: text/plain; charset=us-ascii

On Thu, 12 Jun 2008 14:14:21 +0530, Kamalesh Babulal said:
> Hi Andrew,
> 
> 2.6.26-rc5-mm3 kernel panics while booting up on the x86_64
> machine. Sorry the console is bit overwritten for the first few lines.

> no fstab.kernel BUG at mm/filemap.c:575!

For whatever it's worth, I'm seeing the same thing on my x86_64 laptop.
-rc5-mm2 works OK, I'm going to try to bisect it tonight.

% diff -u /usr/src/linux-2.6.26-rc5-mm[23]/.config
--- /usr/src/linux-2.6.26-rc5-mm2/.config       2008-06-10 22:21:13.000000000 -0400
+++ /usr/src/linux-2.6.26-rc5-mm3/.config       2008-06-12 22:20:25.000000000 -0400
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.26-rc5-mm2
-# Tue Jun 10 22:21:13 2008
+# Linux kernel version: 2.6.26-rc5-mm3
+# Thu Jun 12 22:20:25 2008
 #
 CONFIG_64BIT=y
 # CONFIG_X86_32 is not set
@@ -275,7 +275,7 @@
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-# CONFIG_NORECLAIM_LRU is not set
+CONFIG_UNEVICTABLE_LRU=y
 CONFIG_MTRR=y
 CONFIG_MTRR_SANITIZER=y
 CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0

Not much changed there...


--==_Exmh_1213330723_2983P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFIUfUjcC3lWbTT17ARAkfUAJ0WQuV/bFRJGjGypxnucvdZEPw12QCeK3tg
zb9aq6aIr8XgW+lmCicdQ/Y=
=aeWO
-----END PGP SIGNATURE-----

--==_Exmh_1213330723_2983P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
