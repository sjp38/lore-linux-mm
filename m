Received: from sirius.cs.amherst.edu (localhost.localdomain [127.0.0.1])
	by sirius.cs.amherst.edu (8.12.11/8.12.11) with ESMTP id j8TDtiQL016252
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 09:55:44 -0400
Received: (from sfkaplan@localhost)
	by sirius.cs.amherst.edu (8.12.11/8.12.11/Submit) id j8TDtiiG016249
	for linux-mm@kvack.org; Thu, 29 Sep 2005 09:55:44 -0400
Date: Thu, 29 Sep 2005 09:55:44 -0400
From: "Scott F. H. Kaplan" <sfkaplan@cs.amherst.edu>
Subject: Re: vmtrace
Message-ID: <20050929135544.GA15331@sirius.cs.amherst.edu>
References: <20050928192929.GA19059@logos.cnet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Content-Disposition: inline
In-Reply-To: <20050928192929.GA19059@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Marcelo (and everyone on linux-mm),

On Wed, Sep 28, 2005 at 04:29:29PM -0300, Marcelo Tosatti wrote:

> We've been talking on IRC on how to generate reference traces for
> memory accesses, and a suggestion came up to periodically unmap all
> present pte's of a given process.

There are known accuracy limitations to this approach.  Most
importantly, during any phase change, if you don't unmap the present
PTE's often enough, you will introduce substantial error into any
simulations that use these traces.

> Note: The patch lacks "pte_disable"/"pte_enable" macro pair (those
> are supposed to operate on a free bit in the flags field of the page
> table which was defined as PTE_DISABLE) and "pte_presprotect" macro
> to disable the PTE_PRESENT bit. I had that written down but _I LOST
> MY LAPTOP_ with the complete patch inside :(

Ugh!  Sorry to hear that.  I do have my own PTE_DISABLE and PTE_ENABLE
in the kVMTrace patch that should be easy to extract.  Note, though,
that I found it necessary to use two bits -- one to denote a PTE
disabled by the trace-gathering mechanism, and one to denote a PTE
disabled by a user-level mprotect() request.  This differentiation is
necessary for correctness.

> Scott, do you have any plans to port your work to v2.6? Relayfs
> (present in recent v2.6 kernels) implements a mechanism to send data
> to userspace which is very convenient.

If by ``plans'' you mean ``desire'', then yes; if you mean ``an
organized timeline'', then no.  I must say, though, that the relayfs
sounds as though it will make the porting much easier, allowing me to
strip out the ad-hoc in-kernel logging mechanism that I use in the
2.4-based kVMTrace.

I'm using kVMTrace actively to drive some research.  If there's a
demand for a 2.6-based version of it, then I'm certainly interested in
porting it forward, *especially* if there's anyone out there who would
like to help me along! :-) Most of the hard work isn't in the kernel
-- that portion is simple.  The bulk of the work is in the
post-processing utility that reconstructs the state of every task in
order to attribute each reference to the task that performed it and to
identify all uses of shared memory.  I am hopeful, though, that the
changes from 2.4 to 2.6 won't be all that onerous in this respect.

Scott

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFDO/Jg8eFdWQtoOmgRAtcWAKCUAyPms183qTJwli9g4nVsvn2HqQCgmVKV
lwaccALKoMuyRJDhNuUmnXY=
=ZVGv
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
