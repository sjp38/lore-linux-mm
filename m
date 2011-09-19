Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B429A9000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 15:46:19 -0400 (EDT)
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
In-Reply-To: Your message of "Mon, 19 Sep 2011 18:46:58 +0400."
             <20110919144657.GA5928@albatros>
From: Valdis.Kletnieks@vt.edu
References: <20110910164001.GA2342@albatros> <20110910164134.GA2442@albatros> <20110914192744.GC4529@outflux.net> <20110918170512.GA2351@albatros> <CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
            <20110919144657.GA5928@albatros>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1316461507_2864P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Mon, 19 Sep 2011 15:45:07 -0400
Message-ID: <14082.1316461507@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

--==_Exmh_1316461507_2864P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, 19 Sep 2011 18:46:58 +0400, Vasiliy Kulikov said:

> One note: only to _kernel_ developers.  It means it is a strictly
> debugging feature, which shouldn't be enabled in the production systems=
.

Until somebody at vendor support says =22What does 'cat /proc/slabinfo' s=
ay?=22

Anybody who thinks that debugging tools should be totally disabled on
=22production=22 systems probably hasn't spent enough time actually
running production systems.

--==_Exmh_1316461507_2864P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOd5vDcC3lWbTT17ARAh7JAJwMrRQz4C7zYTO1eHMgucfJzL+1lgCgsuqQ
L4CmG5Vw1ZZf07jYmk/uoDQ=
=YcTW
-----END PGP SIGNATURE-----

--==_Exmh_1316461507_2864P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
