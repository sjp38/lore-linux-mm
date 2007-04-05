Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: Your message of "Wed, 04 Apr 2007 22:37:29 PDT."
             <20070405053729.GQ2986@holomorphy.com>
From: Valdis.Kletnieks@vt.edu
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org> <6701.1175724355@turing-police.cc.vt.edu> <Pine.LNX.4.64.0704041724280.6730@woody.linux-foundation.org> <20070405023026.GE11192@wotan.suse.de>
            <20070405053729.GQ2986@holomorphy.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1175793784_3378P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 05 Apr 2007 13:23:04 -0400
Message-ID: <8350.1175793784@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1175793784_3378P
Content-Type: text/plain; charset=us-ascii

On Wed, 04 Apr 2007 22:37:29 PDT, William Lee Irwin III said:

> The actual phenomenon of concern here is dense matrix code with sparse
> matrix inputs. The matrices will typically not be vast but may span 1MB
> or so of RAM (1024x1024 is 1M*sizeof(double), and various dense matrix
> algorithms target ca. 300x300). Most of the time this will arise from
> the use of dense matrix code as black box solvers called as a library
> by programs not terribly concerned about efficiency until something
> gets explosively inefficient (and maybe not even then), or otherwise
> numerically naive programs. This, however, is arguably the majority of
> the usage cases by end-user invocations, so beware, though not too much.

Amen, brother! :)

At least in my environment, the vast majority of matrix code is actually run by
graduate students under the direction of whatever professor is the Principal
Investigator on the grant. As a rule, you can expect the grad student to know
about rounding errors and convergence issues and similar program *correctness*
factors.  But it's the rare one that has much interest in program *efficiency*.
If it takes 2 days to run, that's 2 days they can go get another few pages of
thesis written while they wait. :)

The code that gets on our SystemX (a top-50 supercomputer still) is usually
well-tweaked for efficiency.  However, that's just one system - there's on the
order of several hundred smaller compute clusters and boxen and SGI-en on
campus where "protect the system from cargo-cult programming by grad students"
is a valid kernel goal. ;)


--==_Exmh_1175793784_3378P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGFTB4cC3lWbTT17ARAr4QAKCUI4s8HRIM5JThdIF9raNWVNBJYwCgsJaQ
P4H7Ye4Ub7tMpNeaEfEZyTc=
=QCOW
-----END PGP SIGNATURE-----

--==_Exmh_1175793784_3378P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
