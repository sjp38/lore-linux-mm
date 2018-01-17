Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92182280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 03:56:32 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g65so3743758wmf.7
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 00:56:32 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id c29si3351627wmi.226.2018.01.17.00.56.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 00:56:31 -0800 (PST)
Date: Wed, 17 Jan 2018 09:56:29 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/1] Re: kernel BUG at fs/userfaultfd.c:LINE!
Message-ID: <20180117085629.GA20303@amd>
References: <20171222222346.GB28786@zzz.localdomain>
 <20171223002505.593-1-aarcange@redhat.com>
 <CACT4Y+av2MyJHHpPQLQ2EGyyW5vAe3i-U0pfVXshFm96t-1tBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline
In-Reply-To: <CACT4Y+av2MyJHHpPQLQ2EGyyW5vAe3i-U0pfVXshFm96t-1tBQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > Andrea Arcangeli (1):
> >   userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK
> >     fails
> >
> >  fs/userfaultfd.c | 20 ++++++++++++++++++--
> >  1 file changed, 18 insertions(+), 2 deletions(-)
>=20
> The original report footer was stripped, so:
>=20
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>

Please don't. We don't credit our CPUs, and we don't credit Qemu. We
credit humans.

> and we also need to tell syzbot about the fix with:
>=20
> #syz fix:
> userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK fails

Now you claimed you care about bugs being fixed. What about actually
testing Andrea's fix and telling us if it fixes the problem or not,
and maybe saying "thank you"?

Thank you,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--tKW2IUtsqtDRztdT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlpfD70ACgkQMOfwapXb+vJ4mwCbBiOye7rXY81/XZEDrhf/d3ZQ
9ZMAn0XYMRhiZrQEC0i+QA5adVGWvKRN
=a93L
-----END PGP SIGNATURE-----

--tKW2IUtsqtDRztdT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
