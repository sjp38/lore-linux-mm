Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E55DF2806E8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:46:50 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 99so1514818qku.9
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:46:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f90si284771qtb.109.2017.05.09.08.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:46:48 -0700 (PDT)
Message-ID: <1494344803.20270.27.camel@redhat.com>
Subject: Re: [RESENT PATCH] x86/mem: fix the offset overflow when read/write
 mem
From: Rik van Riel <riel@redhat.com>
Date: Tue, 09 May 2017 11:46:43 -0400
In-Reply-To: <590A91DF.8030004@huawei.com>
References: <1493293775-57176-1-git-send-email-zhongjiang@huawei.com>
	  <alpine.DEB.2.10.1705021350510.116499@chino.kir.corp.google.com>
	 <1493837167.20270.8.camel@redhat.com> <590A91DF.8030004@huawei.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-JjPeVIH5pRCjcTegOcOj"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Andrew Morton <akpm@linux-foundation.org>, arnd@arndb.de, hannes@cmpxchg.org, kirill@shutemov.name, mgorman@techsingularity.net, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>


--=-JjPeVIH5pRCjcTegOcOj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-05-04 at 10:28 +0800, zhong jiang wrote:
> On 2017/5/4 2:46, Rik van Riel wrote:

> > However, it is not as easy as simply checking the
> > end against __pa(high_memory). Some systems have
> > non-contiguous physical memory ranges, with gaps
> > of invalid addresses in-between.
>=20
> =C2=A0The invalid physical address means that it is used as
> =C2=A0io mapped. not in system ram region. /dev/mem is not
> =C2=A0access to them , is it right?

Not necessarily. Some systems simply have large
gaps in physical memory access. Their memory map
may look like this:

|MMMMMM|IO|MMMM|..................|MMMMMMMM|

Where M is memory, IO is IO space, and the
dots are simply a gap in physical address
space with no valid accesses at all.

> > At that point, is the complexity so much that it no
> > longer makes sense to try to protect against root
> > crashing the system?
> >=20
>=20
> =C2=A0your suggestion is to let the issue along without any protection.
> =C2=A0just root user know what they are doing.

Well, root already has other ways to crash the system.

Implementing validation on /dev/mem may make sense if
it can be done in a simple way, but may not be worth
it if it becomes too complex.

--=20
All rights reversed
--=-JjPeVIH5pRCjcTegOcOj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZEeRjAAoJEM553pKExN6DmXMH/2QGr93b4ksbbP3Pn9+9FIhL
ze+PSXp3QZ0bly2qjNrYyfDgD9xrmMcrUyBCC3WJW8vSQCdtFNB++wVUJDiy6kST
irs2Sk75SpNI3eLiczAsyam8YG/HeeT1qvGrETSAEVPakq44iG420MH1Z3Ybwhan
acPgZ5HogIVjAwCv7Lf0NZIvTty3FvtVIIuNY2AdKVp9QIVZ23yaChWYH4CjiFwG
oKm7eA4sp7+NtYayaDkhVqN/zeW7qFYDbPEvJYd7yYmntCniERTcGg7rkNaFQMP5
mGuz2PQimAJeKFxlVsaAfQHtjgVkIwBbDoVRmHNsSoV5wMN5+YZI2h7ZoIdlYBo=
=zwKo
-----END PGP SIGNATURE-----

--=-JjPeVIH5pRCjcTegOcOj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
