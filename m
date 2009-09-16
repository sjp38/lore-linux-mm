Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CEFF16B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 02:06:57 -0400 (EDT)
Date: Wed, 16 Sep 2009 16:06:51 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: 2.6.32 -mm Blackfin patches
Message-Id: <20090916160651.88b10377.sfr@canb.auug.org.au>
In-Reply-To: <8bd0f97a0909152124n186278feja97a7257548b3eb7@mail.gmail.com>
References: <8bd0f97a0909152056h61bfc487g6b8631966c6d72be@mail.gmail.com>
	<20090915211810.d1b83015.akpm@linux-foundation.org>
	<8bd0f97a0909152124n186278feja97a7257548b3eb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__16_Sep_2009_16_06_51_+1000_1=K.bXQQyL..JnBs"
Sender: owner-linux-mm@kvack.org
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Signature=_Wed__16_Sep_2009_16_06_51_+1000_1=K.bXQQyL..JnBs
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Mike,

On Wed, 16 Sep 2009 00:24:37 -0400 Mike Frysinger <vapier.adi@gmail.com> wr=
ote:
>
> not sure how the next process works.  what do i need to do Stephen ?

You send me a request for inclusion with a git tree (and branch)  (or
quilt series on a web site) and contact address(es) and understand the
following:

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgment of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
	Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

Legal Stuff:
By participating in linux-next, your subsystem tree contributions are
public and will be included in the linux-next trees.  You may be sent
e-mail messages indicating errors or other issues when the
patches/commits from your subsystem tree are merged and tested in
linux-next.  These messages may also be cross-posted to the linux-next
mailing list, the linux-kernel mailing list, etc.  The linux-next tree
project and IBM (my employer) make no warranties regarding the linux-next
project, the testing procedures, the results, the e-mails, etc.  If you
don't agree to these ground rules, let me know and I'll remove your tree
from participation in linux-next.

--Signature=_Wed__16_Sep_2009_16_06_51_+1000_1=K.bXQQyL..JnBs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkqwgHsACgkQjjKRsyhoI8zBUACglz37aqTcrkJeAwE4hNoWxUqJ
7kAAn3UOr8XF7Lnly7sMvSuzS9RuZQD4
=zeFd
-----END PGP SIGNATURE-----

--Signature=_Wed__16_Sep_2009_16_06_51_+1000_1=K.bXQQyL..JnBs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
