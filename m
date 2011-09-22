Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F11579000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 22:22:23 -0400 (EDT)
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
In-Reply-To: Your message of "Wed, 21 Sep 2011 21:05:27 +0400."
             <20110921170527.GA15869@albatros>
From: Valdis.Kletnieks@vt.edu
References: <20110910164001.GA2342@albatros> <20110910164134.GA2442@albatros> <20110914192744.GC4529@outflux.net> <20110918170512.GA2351@albatros> <CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com> <20110919144657.GA5928@albatros> <14082.1316461507@turing-police.cc.vt.edu> <20110919205541.1c44f1a3@bob.linux.org.uk>
            <20110921170527.GA15869@albatros>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1316658054_3192P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 21 Sep 2011 22:20:54 -0400
Message-ID: <26246.1316658054@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Alan Cox <alan@linux.intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <gregkh@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

--==_Exmh_1316658054_3192P
Content-Type: text/plain; charset=us-ascii

On Wed, 21 Sep 2011 21:05:27 +0400, Vasiliy Kulikov said:
> Sorry, I've poorly worded my statement.  Of course I mean root-only
> slabinfo, not totally disable it.

Oh, that I can live with.. ;)

> Linus, Alan, Kees, and Dave are about to simply restrict slabinfo (and
> probably similar interfaces) to root.  Pekka is OK too.
> 
> Christoph and Valdis are about to create new CONFIG_ option to be able
> to restrict the access to slabinfo/etc., but with old relaxed
> permissions.

I'm OK with a decision to just make the files mode 400 and be done with it,
since I can always stick a chmod in the startup scripts if it's *really* a problem.

Just that *if* we add a CONFIG_ option, it shouldn't be slabinfo-specific, but
should cover the *other* identified info-leakers in /proc and /sys as well.

--==_Exmh_1316658054_3192P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOepuGcC3lWbTT17ARAsq9AJ9E8yOpWF0HzbRTxIDnYJIKMmiEjQCfd4G5
yzAWYuWP4CsLqZ+6joEb/l8=
=yxmF
-----END PGP SIGNATURE-----

--==_Exmh_1316658054_3192P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
