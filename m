Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5926B0005
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:47:37 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e93-v6so18658660plb.5
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:47:37 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id r12-v6si27347514pfd.193.2018.07.13.19.47.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Jul 2018 19:47:36 -0700 (PDT)
Date: Sat, 14 Jul 2018 12:47:28 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2018-07-13-16-51 uploaded (PSI)
Message-ID: <20180714124728.562ff3af@canb.auug.org.au>
In-Reply-To: <cf4f5b65-6333-a1f0-6118-16fc0e5bc221@infradead.org>
References: <20180713235138.HoxHd%akpm@linux-foundation.org>
	<cf4f5b65-6333-a1f0-6118-16fc0e5bc221@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/cSnV=4v+WpvU7pDVBd56S1W"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, broonie@kernel.org, mhocko@suse.cz, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

--Sig_/cSnV=4v+WpvU7pDVBd56S1W
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Fri, 13 Jul 2018 18:41:40 -0700 Randy Dunlap <rdunlap@infradead.org> wro=
te:
>
> On 07/13/2018 04:51 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2018-07-13-16-51 has been uploaded to
> >=20
> >    http://www.ozlabs.org/~akpm/mmotm/
> >=20
> > mmotm-readme.txt says
> >=20
> > README for mm-of-the-moment:
> >=20
> > http://www.ozlabs.org/~akpm/mmotm/
> >=20
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> >=20
> > You will need quilt to apply these patches to the latest Linus release =
(4.x
> > or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated=
 in
> > http://ozlabs.org/~akpm/mmotm/series
> >=20
> > The file broken-out.tar.gz contains two datestamp files: .DATE and
> > .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> > followed by the base kernel version against which this patch series is =
to
> > be applied. =20
>=20
>=20
> ../include/linux/psi.h:12:13: error: conflicting types for 'psi_disabled'
> extern bool psi_disabled;
>=20
>=20
> choose one:)
>=20
> kernel/sched/psi.c:
> bool psi_disabled __read_mostly;
>=20
>=20
> include/linux/sched/stat.h:
> 	extern int psi_disabled;

I have added this to linux-next (in case Andrew doesn't have time to
revise mmotm):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Sat, 14 Jul 2018 12:35:19 +1000
Subject: [PATCH]  psi-pressure-stall-information-for-cpu-memory-and-io-fix-=
fix-fix

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/sched/stat.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/sched/stat.h b/include/linux/sched/stat.h
index ac39435d1521..bd477b819237 100644
--- a/include/linux/sched/stat.h
+++ b/include/linux/sched/stat.h
@@ -31,7 +31,7 @@ static inline int sched_info_on(void)
 	if (delayacct_on)
 		return 1;
 #elif defined(CONFIG_PSI)
-	extern int psi_disabled;
+	extern bool psi_disabled;
 	if (!psi_disabled)
 		return 1;
 #endif
--=20
2.18.0

--=20
Cheers,
Stephen Rothwell

--Sig_/cSnV=4v+WpvU7pDVBd56S1W
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAltJZEAACgkQAVBC80lX
0GwK3wf+Os6pRMdZfpbKSD5a2x0xR30Pin0lr8kdsqUFegBcfJyZXbVOZO7j6KKX
ft08/CzR1yk/rVQ3VI4s3mX0VgzzrzSBnkGf4NCSyrQjHsPR2ZebjVBxPIav8Rfl
HQ94nNJ3HwuQtZDkSJfMljpA7LTUHzKFYazZQ3X825JtDLsaSM2HF2KT8t69wCTI
UDHBs8GJ1ZSQe6ug11fL41i5rnU8FiH7fTaIiAHVixgZ+KSAqFVJeUiFYULgAW4+
FRdfV8NVNqznNb/xZJJTWD5jzp8Bu9C/uMXsrTZW3EVPhZesaHFhYh03wqNyWa+W
93+ps8XDP04xptRpvFh0CE2h8ZpQqQ==
=xWxi
-----END PGP SIGNATURE-----

--Sig_/cSnV=4v+WpvU7pDVBd56S1W--
