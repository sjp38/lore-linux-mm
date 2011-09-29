Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 660549000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 20:45:03 -0400 (EDT)
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
In-Reply-To: Your message of "Wed, 28 Sep 2011 13:31:45 PDT."
             <1317241905.16137.516.camel@nimitz>
From: Valdis.Kletnieks@vt.edu
References: <20110927175453.GA3393@albatros> <20110927175642.GA3432@albatros> <20110927193810.GA5416@albatros> <alpine.DEB.2.00.1109271459180.13797@router.home> <alpine.DEB.2.00.1109271328151.24402@chino.kir.corp.google.com> <alpine.DEB.2.00.1109271546320.13797@router.home>
            <1317241905.16137.516.camel@nimitz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1317257024_2944P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Sep 2011 20:43:44 -0400
Message-ID: <30918.1317257024@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@gentwo.org>, David Rientjes <rientjes@google.com>, Vasiliy Kulikov <segoon@openwall.com>, kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

--==_Exmh_1317257024_2944P
Content-Type: text/plain; charset=us-ascii

On Wed, 28 Sep 2011 13:31:45 PDT, Dave Hansen said:

> We could also just _effectively_ make it output in MB:
> 
> 	foo = foo & ~(1<<20)
> 
> or align-up.

I think we want align-up here, there's a bunch of fields that code probably
expects to be non-zero on a system that's finished booting...

> We could also give the imprecise numbers to unprivileged
> users and let privileged ones see the page-level ones.

That also sounds like a good idea.

--==_Exmh_1317257024_2944P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOg79AcC3lWbTT17ARAmqiAJ9V4cm5nViiDdSy1BfRSTUxIHFRvwCfScmt
aoEo4KjbCZekOI0n/qkZOTc=
=CRrZ
-----END PGP SIGNATURE-----

--==_Exmh_1317257024_2944P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
