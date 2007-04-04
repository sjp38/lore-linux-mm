Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: Your message of "Wed, 04 Apr 2007 17:48:39 +0200."
             <20070404154839.GI19587@v2.random>
From: Valdis.Kletnieks@vt.edu
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
            <20070404154839.GI19587@v2.random>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1175724468_4061P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 04 Apr 2007 18:07:48 -0400
Message-ID: <6749.1175724468@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1175724468_4061P
Content-Type: text/plain; charset=us-ascii

On Wed, 04 Apr 2007 17:48:39 +0200, Andrea Arcangeli said:

> Ok, those cases wanting the same zero page, could be fairly easily
> converted to an mmap over /dev/zero (without having to run 4k large
> mmap syscalls or nonlinear).

"D'oh!" -- H. Simpson.

Ignore my previous note. :)

--==_Exmh_1175724468_4061P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGFCG0cC3lWbTT17ARAjYxAKCpG4N9RGrtLhxK9kBzJ+tJ+nf28QCeJwSr
1jNBedWn8Wv5qgILMADZETQ=
=RFik
-----END PGP SIGNATURE-----

--==_Exmh_1175724468_4061P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
