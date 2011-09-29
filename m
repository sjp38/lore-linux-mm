Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 70B3F9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 12:58:44 -0400 (EDT)
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
In-Reply-To: Your message of "Thu, 29 Sep 2011 20:18:48 +0400."
             <20110929161848.GA16348@albatros>
From: Valdis.Kletnieks@vt.edu
References: <20110927175453.GA3393@albatros> <20110927175642.GA3432@albatros> <20110927193810.GA5416@albatros> <alpine.DEB.2.00.1109271459180.13797@router.home> <alpine.DEB.2.00.1109271328151.24402@chino.kir.corp.google.com>
            <20110929161848.GA16348@albatros>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1317315452_4004P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 29 Sep 2011 12:57:32 -0400
Message-ID: <23921.1317315452@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@gentwo.org>, kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

--==_Exmh_1317315452_4004P
Content-Type: text/plain; charset=us-ascii

On Thu, 29 Sep 2011 20:18:48 +0400, Vasiliy Kulikov said:

> As `new' is just increased, it means it is known with KB granularity,
> not MB.  By counting used slab objects he learns filled_obj_size_sum.
> 
> So, rounding gives us nothing, but obscurity.

Yes, but if he has an exploit that requires using up (for example) exactly 31
objects in the slab, he may now know that a new slab got allocated to push it
over the MB boundary.  So he knows there's exactly one object in that new slab.

But now he has to fly blind for the next 30 because the numbers will display
exactly the same, and he can't correct for somebody else allocating one so he
needs to only allocate 29...


--==_Exmh_1317315452_4004P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOhKN8cC3lWbTT17ARAg/3AJ9x3uaMuHNlfdBtk8pRkToHP403mACglOOW
87NfvBJfy887ga+I5IdAQY0=
=H0IU
-----END PGP SIGNATURE-----

--==_Exmh_1317315452_4004P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
