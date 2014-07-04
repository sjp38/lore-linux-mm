Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6116B0031
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 11:16:30 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so1802021wes.35
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 08:16:30 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id cm10si12186046wjb.100.2014.07.04.08.16.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jul 2014 08:16:29 -0700 (PDT)
From: =?ISO-8859-1?Q?C=E9dric?= Villemain <cedric@2ndquadrant.com>
Reply-To: cedric@2ndquadrant.com
Subject: Re: [PATCH v2 2/4] mm: introduce fincore()
Date: Fri, 04 Jul 2014 17:15:59 +0200
Message-ID: <5816450.BPnLjGgtl5@obelix>
In-Reply-To: <20140704101230.GA24688@infradead.org>
References: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1404424335-30128-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20140704101230.GA24688@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart8084549.9xpDVVycgD"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>


--nextPart8084549.9xpDVVycgD
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

Le vendredi 4 juillet 2014 03:12:30 Christoph Hellwig a =E9crit :
> On Thu, Jul 03, 2014 at 05:52:13PM -0400, Naoya Horiguchi wrote:
> > This patch provides a new system call fincore(2), which provides
> > mincore()- like information, i.e. page residency of a given file.
> > But unlike mincore(), fincore() has a mode flag which allows us to
> > extract detailed information about page cache like pfn and page
> > flag. This kind of information is very helpful, for example when
> > applications want to know the file cache status to control the IO
> > on their own way.
>=20
> It's still a nasty multiplexer for multiple different reporting
> formats in a single system call.  How about your really just do a
> fincore that mirrors mincore instead of piggybacking exports of
> various internal flags (tags and page flags onto it.

The fincore =E0 la mincore got some arguments against it too. It seems =
this=20
implementations try (I've not tested nor have a close look yet) to=20
answer both concerns : have details and also possible to have=20
aggregation function not too expansive.

=2D-=20
C=E9dric Villemain +33 (0)6 20 30 22 52
http://2ndQuadrant.fr/
PostgreSQL: Support 24x7 - D=E9veloppement, Expertise et Formation
--nextPart8084549.9xpDVVycgD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABAgAGBQJTtsUyAAoJENsgH0yzVBebWBoIAJhFEeV28nzkW/C4Wi3s8YXZ
CgfL6Kpu1jvhMQC/5ni4RquqQoZtRtHU1/qBuW5e1njazdflWhTRxsf3zff3mOMD
owZbKbi8s8UT9m/uEB9Yv9vXFmiWhpXL+yqcniQWW5WUNCIP/X3F/fMVzlaydrCb
vUQlXvJ1p0sUrtualRry3sQpPk/OxT0Fa1n3HdiC4X9wfv0EX8OSXjekZqtUS0NC
OUsXEfnaB/KmbiqRLGBgxoofynMby2089Cgi13+MHFvS32YzRA+x0/dbKUJmpN2I
j0FCbJEc982/BIK2vpSPZk+/0ZZkWjYDx5RNHGuwYc1FimvN4UdgR4AHnp9DWo8=
=AC/X
-----END PGP SIGNATURE-----

--nextPart8084549.9xpDVVycgD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
