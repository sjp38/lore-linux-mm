Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 358619000C2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 19:33:33 -0400 (EDT)
Subject: Re: [PATCH 0/5] mm,debug: VM framework to capture memory reference pattern
In-Reply-To: Your message of "Tue, 05 Jul 2011 13:52:34 +0530."
             <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
From: Valdis.Kletnieks@vt.edu
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1309908804_18528P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 05 Jul 2011 19:33:24 -0400
Message-ID: <64797.1309908804@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

--==_Exmh_1309908804_18528P
Content-Type: text/plain; charset=us-ascii

On Tue, 05 Jul 2011 13:52:34 +0530, Ankita Garg said:

> by default) and scans through all pages of the specified tasks (including
> children/threads) running in the system. If the hardware reference bit in the
> page table is set, then the page is marked as accessed over the last sampling
> interval and the reference bit is cleared.

Does that cause any issues for other code in the mm subsystem that was
expecting to use the reference bit for something useful? (Similarly, if other
code in mm turns that bit *off* for its own reasons, does your code still
produce useful results?)

--==_Exmh_1309908804_18528P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOE59EcC3lWbTT17ARAgICAJ0eK8nvfFWBX/my5unboxcW+kwR1wCfe09X
iuBPwUv3052e06A6+wQsgOk=
=/A6K
-----END PGP SIGNATURE-----

--==_Exmh_1309908804_18528P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
