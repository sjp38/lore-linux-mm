Message-Id: <200301281722.h0SHMHgM006963@turing-police.cc.vt.edu>
Subject: Re: [PATCH] page coloring for 2.5.59 kernel, version 1 
In-Reply-To: Your message of "Tue, 28 Jan 2003 12:06:11 EST."
             <Pine.LNX.3.96.1030128120205.32466B-100000@gatekeeper.tmr.com>
From: Valdis.Kletnieks@vt.edu
References: <Pine.LNX.3.96.1030128120205.32466B-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1567796551P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Jan 2003 12:22:17 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1567796551P
Content-Type: text/plain; charset=us-ascii

On Tue, 28 Jan 2003 12:06:11 EST, Bill Davidsen said:

> I have noted in ctxbench that the SMP results have a vast performance
> range while the uni (and nosmp) don't. Not clear if this would improve
> that, but I sure would like to try.

Another thing to check is whether in the SMP case, there's a race condition
with optimal/pessimal grabbing of locks, etc.

--==_Exmh_1567796551P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQE+NrxJcC3lWbTT17ARAtpVAJ47i0HV3k8LxEgC00WYGOWUQS1HgACg8tu/
lVsvMFlI2uCh7oD4vq8QtR8=
=cUMR
-----END PGP SIGNATURE-----

--==_Exmh_1567796551P--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
