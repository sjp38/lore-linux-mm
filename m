Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 29F116B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 21:08:50 -0400 (EDT)
Subject: Re: mmotm 2011-04-29 - wonky VmRSS and VmHWM values after swapping
In-Reply-To: Your message of "Tue, 10 May 2011 18:04:45 +0200."
             <1305043485.2914.110.camel@laptop>
From: Valdis.Kletnieks@vt.edu
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org> <49683.1304296014@localhost> <8185.1304347042@localhost> <20110502164430.eb7d451d.akpm@linux-foundation.org>
            <1305043485.2914.110.camel@laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1305162521_2485P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 May 2011 21:08:41 -0400
Message-ID: <3313.1305162521@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--==_Exmh_1305162521_2485P
Content-Type: text/plain; charset=us-ascii

On Tue, 10 May 2011 18:04:45 +0200, Peter Zijlstra said:

> I haven't quite figured out how to reproduce, but does the below cure
> things? If so, it should probably be folded into the first patch
> (mm-mmu_gather-rework.patch?) since that is the one introducing this.
> 
> ---
> Subject: mm: Fix RSS zap_pte_range() accounting
> 
> Since we update the RSS counters when breaking out of the loop and
> release the PTE lock, we should start with fresh deltas when we
> restart the gather loop.

Confirming this patch makes the numbers look sane and plausible again, so
feel free to stick a Tested-By: to match the Reported-By:.

--==_Exmh_1305162521_2485P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNyzMZcC3lWbTT17ARApyMAKCJfiHzhEgR8XwpgnhK12nzEBoNUgCgpXah
1caMfu6xRn68C2XkrP7CCMI=
=lTLb
-----END PGP SIGNATURE-----

--==_Exmh_1305162521_2485P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
