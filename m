Message-ID: <461494FE.1040403@redhat.com>
Date: Wed, 04 Apr 2007 23:19:42 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	<20070403125903.3e8577f4.akpm@linux-foundation.org>	<4612B645.7030902@redhat.com>	<20070403202937.GE355@devserv.devel.redhat.com>	<20070403144948.fe8eede6.akpm@linux-foundation.org>	<4612DCC6.7000504@cosmosbay.com>	<46130BC8.9050905@yahoo.com.au>	<1175675146.6483.26.camel@twins>	<461367F6.10705@yahoo.com.au>	<20070404113447.17ccbefa.dada1@cosmosbay.com>	<46137882.6050708@yahoo.com.au> <20070404135458.4f1a7059.dada1@cosmosbay.com> <4614585F.1050200@yahoo.com.au> <461492A5.1030905@cosmosbay.com>
In-Reply-To: <461492A5.1030905@cosmosbay.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig33B43440A24F4E88EB661303"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig33B43440A24F4E88EB661303
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Eric Dumazet wrote:
> Database workload, where the user multi threaded app is constantly
> accessing GBytes of data, so L2 cache hit is very small. If you want to=

> oprofile it, with say a CPU_CLK_UNHALTED:5000 event, then find_vma() is=

> in the top 5.

We did have a workload with lots of Java and databases at some point
when many VMAs were the issue.  I brought this up here one, maybe two
years ago and I think Blaisorblade went on and looked into avoiding VMA
splits by having mprotect() not split VMAs and instead store the flags
in the page table somewhere.  I don't remember the details.

Nothing came out of this but if this is possible it would be yet another
way to avoid mmap_sem locking, right?

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enig33B43440A24F4E88EB661303
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGFJT+2ijCOnn/RHQRAj1UAKCe5X7q/IB9Yt4t2wfmnC+jdm5UlACfcnia
TSpVQxWQnRQCq0PQgwAQiSc=
=pgqX
-----END PGP SIGNATURE-----

--------------enig33B43440A24F4E88EB661303--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
