Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 72AC06B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 15:31:37 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id h185so221093413vkg.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 12:31:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h189si18340496qhd.2.2016.04.15.12.31.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 12:31:36 -0700 (PDT)
Message-ID: <1460748682.25336.41.camel@redhat.com>
Subject: Re: [Bug 107771] New: Single process tries to use more than 1/2
 physical RAM, OS starts thrashing
From: Rik van Riel <riel@redhat.com>
Date: Fri, 15 Apr 2016 15:31:22 -0400
In-Reply-To: <20160415121549.47e404e3263c71564929884e@linux-foundation.org>
References: <bug-107771-27@https.bugzilla.kernel.org/>
	 <20160415121549.47e404e3263c71564929884e@linux-foundation.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-3dBXzDUI2y/coimDsBba"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, theosib@gmail.com


--=-3dBXzDUI2y/coimDsBba
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-04-15 at 12:15 -0700, Andrew Morton wrote:
> (switched to email.=C2=A0=C2=A0Please respond via emailed reply-to-all, n=
ot via
> the
> bugzilla web interface).
>=20
> This is ... interesting.

First things first. What is the value of
/proc/sys/vm/zone_reclaim?

I am assuming this is a two socket system,
with two 12-core CPUs. Am I right?

> On Thu, 12 Nov 2015 18:46:35 +0000 bugzilla-
> daemon@bugzilla.kernel.org wrote:
>=20
> >=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D107771
> >=20
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0Bug ID: 107771
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Summa=
ry: Single process tries to use more than 1/2
> > physical
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0RAM, OS starts thrashing
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Produ=
ct: Memory Management
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Versi=
on: 2.5
> > =C2=A0=C2=A0=C2=A0=C2=A0Kernel Version: 4.3.0-040300-generic (Ubuntu)
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Hardware: A=
ll
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0OS: Linux
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0Tree: Mainline
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0Status: NEW
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Severity: n=
ormal
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Priority: P=
1
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Component: Page A=
llocator
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Assignee: a=
kpm@linux-foundation.org
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Reporter: t=
heosib@gmail.com
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Regression: No
> >=20
> > I have a 24-core (48 thread) system with 64GB of RAM.=C2=A0=C2=A0
> >=20
> > When I run multiple processes, I can use all of physical RAM before
> > swapping
> > starts.=C2=A0=C2=A0However, if I'm running only a *single* process, the
> > system will start
> > swapping after I've exceeded only 1/2 of available physical
> > RAM.=C2=A0=C2=A0Only after
> > swap fills does it start using more of the physical RAM.=C2=A0=C2=A0
> >=20
> > I can't find any ulimit settings or anything else that would cause
> > this to
> > happen intentionally.=C2=A0
> >=20
> > I had originally filed this against Ubuntu, but I'm now running a
> > more recent
> > kernel, and the problem persists, so I think it's more appropriate
> > to file
> > here.=C2=A0=C2=A0There are some logs that they had me collect, so if yo=
u want
> > to see
> > them, the are here:
> >=20
> > https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1513673
> >=20
> > I don't recall this problem happening with older kernels (whatever
> > came with
> > Ubuntu 15.04), although I may just not have noticed.=C2=A0=C2=A0By swap=
ping
> > early, I'm
> > limited by the speed of my SSD, which is moving only about 20MB/sec
> > in each
> > direction, and that makes what I'm running take 10 times as long to
> > complete.
> >=20
--=20
All Rights Reversed.


--=-3dBXzDUI2y/coimDsBba
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXEUGLAAoJEM553pKExN6DalEIAJglyPn2Nx+0IzCbjmipdA1J
uLUjD2aIrBFWlObysRnM0m1NiLCz/luroMn1SHR2EinRDQhXlimt67/Idd3kC5yO
bW4yS3GgNUYB82pFtkzhViGIfFAjCTWzaiPPkbNSRPpAmbu0GpznEO6Fwc0IIUM4
F9fhOiCRMiD1SFb4RiotrT7r9ONyCPf2ihGx30HK6Pwkz3i+ZH/Eko/51OE5c55S
0N4hqOffXssuegD35vfYfuCcyVvWGpgddlUpHYhZJ0mckrtAfS+C0UjXJ+Ag1Qad
zBEBrij6FeGMuztlKX16ZGLEQgyW0wb1VdhzAjxfgzzyTMOpp944d5PnstCuOc8=
=Dhd2
-----END PGP SIGNATURE-----

--=-3dBXzDUI2y/coimDsBba--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
