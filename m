Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 71C726B004D
	for <linux-mm@kvack.org>; Tue, 22 May 2012 02:50:47 -0400 (EDT)
Date: Tue, 22 May 2012 16:50:35 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [tip:perf/uprobes] uprobes, mm, x86: Add the ability to install
 and remove uprobes breakpoints
Message-Id: <20120522165035.b2beb151ac9c4efbaf30a3eb@canb.auug.org.au>
In-Reply-To: <20120521192700.71bfda5f.akpm@linux-foundation.org>
References: <20120209092642.GE16600@linux.vnet.ibm.com>
	<tip-2b144498350860b6ee9dc57ff27a93ad488de5dc@git.kernel.org>
	<20120521143701.74ab2d0b.akpm@linux-foundation.org>
	<CA+55aFw5ccuvvtyf6iuuw-Finr79ZkPxgCxL5jNvdnX5oMYkgg@mail.gmail.com>
	<20120521151323.f23bd5e9.akpm@linux-foundation.org>
	<20120522111618.ca91892dc6027f9a4251235e@canb.auug.org.au>
	<20120521192700.71bfda5f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__22_May_2012_16_50_35_+1000_HDfBWxpbPVyapGir"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, mingo@redhat.com, a.p.zijlstra@chello.nl, peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com, jkenisto@us.ibm.com, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, vda.linux@googlemail.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com, roland@hack.frob.com, mingo@elte.hu, linux-tip-commits@vger.kernel.org

--Signature=_Tue__22_May_2012_16_50_35_+1000_HDfBWxpbPVyapGir
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Mon, 21 May 2012 19:27:00 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> On Tue, 22 May 2012 11:16:18 +1000 Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
>=20
> > I have been meaning to talk to you about basing the majority of your
> > patch series on Linus' tree.  This would give it mush greater stability
> > and would make the merge resolution my problem (and Linus', of course).
>=20
> Confused.  None of those conflicts have anything to do with the -mm
> patches: the only trees involved there are mainline and
> trees-in-next-other-than-mm.

Right, its a separate issue.  Though I do end up coping with conflicts in
the -mm tree as I have to rebase it everyday.

> > There will be bits that may need to be based on other work in linux-nex=
t,
> > but I suspect that it is not very much.
>=20
> Well, there are a number of reasons why I base off linux-next.  To see
> whether others have merged patches which I have merged (and, sometimes,
> missed later fixes to them).  Explicit fixes against -next material.=20
> To get visibility into upcoming merge problems.  And so that I and
> others test -next too.

I guess I see a separation between what you are working on and what you
are publishing.  You used to publish a reasonable amount of subseries for
others and most of this I suspect could just be based on Linus' tree.
Anyway, not a big problem except when I get days like yesterday (when I
saw some of the conflicts you are noting).

> Basing -mm on next is never a problem (for me).  What is a problem is
> the mess which happens when people merge things into mainline which are
> (I assume) either slightly different from what they merged in -next or
> which never were in -next at all.

Indeed.  Some of what you have seen this time is just last minute updates
of other trees and bug fixes in Linus' tree.  We had about 2000 (net)
commits added to linux-next in the past week (800+ over the weekend).
Some of this has now migrated to Linus' tree already.

> That's guessing - it's a long time since I sat down and worked out exactly
> what is causing this.

Which is not a trivial problem.  I will run my stats script and see what
pops out.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__22_May_2012_16_50_35_+1000_HDfBWxpbPVyapGir
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPuzc7AAoJEECxmPOUX5FEKVAQAJ4BsKg5cmGDKBgIemqS05g4
KM/e2VCmn4vG3NmtQXw31IFZv0JmKswSb69QyF1oA6oQKjR/XajyXLJpDWmUNVWr
4p1bVp87zn5VLU+FEHzklX8qiLvfpttq89W521+sihama08it6azjtK0K2fW7NaV
LJmMpb4+ry9KVsHk/YsfyKm43oiXYQUdbPQuaJ7WdLmeXMnfRnXObZBihr5hbwSg
29hpL5pl/GsLKKkNJcG0JFBKaueLMXvxilWJHSTgBrpzyzylDtZAdrwJ6frRHo5j
H6nWlcJUO0ROhP3v12SwqgbX4wtssOuZ29vSdbsGYlqsY9+LgvMpNZps3BFdl8E9
SdU8CElqiPAK9DsMOD9VPWN4lYJPdkTLEum33V2MMfzzysX/pGsYRE7xoGU7fVNs
RHYwCsz1tYTrzbYkYoQGZ4mYBi1DWnoe7tQur+zdPimJbJUMyXvVF0hEvIC1VY3l
TyDZwRPHQsCM9iY389DYNLhA/k5EtPi7sdm5iqnOzgaZmByfSonsAJMho/fjZRb4
EETU248lkFWuoPUL2Iz4lIjEEkS2ewZI9WdPOqTyg8b0pnTsKsLPeveQkxovPy7R
Tlj3oVG3dSOjjUmSx0vIiz4Om+W9j6NJY9OFaEvgu9IPLYMjmOkS/HYr+rzC4iQI
7YKld7fI5PoVDcFeF6up
=goTK
-----END PGP SIGNATURE-----

--Signature=_Tue__22_May_2012_16_50_35_+1000_HDfBWxpbPVyapGir--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
