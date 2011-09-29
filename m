Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 15A459000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 12:43:41 -0400 (EDT)
Date: Thu, 29 Sep 2011 12:43:19 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 0/9] V2: idle page tracking / working set estimation
Message-ID: <20110929164319.GA3509@mgebm.net>
References: <1317170947-17074-1-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lrZ03NoBR/3+SXJZ"
Content-Disposition: inline
In-Reply-To: <1317170947-17074-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 27 Sep 2011, Michel Lespinasse wrote:

> This is a followup to the prior version of this patchset, which I sent out
> on September 16.
>=20
> I have addressed most of the basic feedback I got so far:
>=20
> - Renamed struct pr_info -> struct page_referenced_info
>=20
> - Config option now depends on 64BIT, as we may not have sufficient
>   free page flags in 32-bit builds
>=20
> - Renamed mem -> memcg in kstaled code within memcontrol.c
>=20
> - Uninlined kstaled_scan_page
>=20
> - Replaced strict_strtoul -> kstrtoul
>=20
> - Report PG_stale in /proc/kpageflags
>=20
> - Fix accounting of THP pages. Sorry for forgeting to do this in the
>   V1 patchset - to detail the change here, what I had to do was make sure
>   page_referenced() reports THP pages as dirty (as they always are - the
>   dirty bit in the pmd is currently meaningless) and update the minimalis=
tic
>   implementation change to count THP pages as equivalent to 512 small pag=
es.
>=20
> - The ugliest parts of patch 6 (rate limit pages scanned per second) have
>   been reworked. If the scanning thread gets delayed, it tries to catch up
>   so as to minimize jitter. If it can't catch up, it would probably be a
>   good idea to increase the scanning interval, but this is left up
>   to userspace.
>=20

Michel,

I have been trying to test these patches since yesterday afternoon.  When my
machine is idle, they behave fine.  I started looking at performance to make
sure they were a big regression by testing kernel builds with the scanner
disabled, and then enabled (set to 120 seconds).  The scanner disabled buil=
ds
work fine, but with the scanner enabled the second time I build my kernel h=
angs
my machine every time.  Unfortunately, I do not have any more information t=
han
that for you at the moment.  My next step is to try the same tests in qemu =
to
see if I can get more state information when the kernel hangs.

Eric

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOhKAnAAoJEH65iIruGRnNcZgH/AxQwlnAQEf6s6kshaySU13c
ajC2JFmE2Zya4RM727lDivMid9Ybipqdc+loA7JT6yojPhKptvU8DbxRrf2pRVf4
cNvZSfbAwx4EIXQQisprz6XhLX2hRMx/M4STvbHxZhbHTzZiPDueKUveONQlul8x
2suGBmjbv0FLCNNXhZFtxz9JWrWhudV2UiJFd3l54/fSx1gBGpD4EM8KC4+E4HW7
6p4dKk102O4ItGRhM6wRY9B+o2rN+1YBBHnRyE0XhGqijwA4QVYVx5v3VErmWZhc
6p4PLL4Lf09qDTi6hk3z5jK25L+qPJlJm04udgCwmzOPjUR5vCB5XyZUfdh45eM=
=5/Qm
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
