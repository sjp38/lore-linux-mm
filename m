Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 151A76B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 10:51:59 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so7208980pdj.8
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 07:51:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 9si1205937pdk.145.2014.07.08.07.51.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 07:51:56 -0700 (PDT)
Date: Tue, 8 Jul 2014 16:51:47 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mm/sched/net: BUG when running simple code
Message-ID: <20140708145147.GH6758@twins.programming.kicks-ass.net>
References: <539A6850.4090408@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="D3uGefx/nfj0hkMF"
Content-Disposition: inline
In-Reply-To: <539A6850.4090408@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>


--D3uGefx/nfj0hkMF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 12, 2014 at 10:56:16PM -0400, Sasha Levin wrote:
> Hi all,
>=20
> Okay, I'm really lost. I got the following when fuzzing, and can't really=
 explain what's
> going on. It seems that we get a "unable to handle kernel paging request"=
 when running
> rather simple code, and I can't figure out how it would cause it.
>=20

Are you running on AMD hardware? If so; check out this thread:

  http://marc.info/?i=3D53B02CEB.7010607@web.de

--D3uGefx/nfj0hkMF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTvAWDAAoJEHZH4aRLwOS6VnEP/05c2sj5PFztHzQWIEtZ7xo7
C9fdGJntcS00lx8pqS8e2wL8j5lk3LJZiJppgtH1xNXVGIKFE03vTgt+K+W6WFtA
KHZhFlarHk73JEZhFD1aCcqUC9mqfY6vOgy3FuluQg029OnAxSQQ52xDEiiYPODx
9VugzaxExZmWk0ke13szomqq8adbwjYCc5pWUIPNf1QbdUhj/w5X05ppDoNqz4TP
mLAgu7aLkYW0HaXgk3Qi0nUKcbHrQ+iBB8qmifWNw3oVMW9dsrJ3DQdYFK74EfE3
89o8kd9TxjInToggT3dFKYJNHISikolaGVFr5lfVOeOLJkegobA9eCwgVZ8vrjO4
QNt6Mu9dkYO0ZpyC/7VJZl02uILeMtKEPU3lcn8EKPAlb9UUsBrPEoI2m5e/my7F
uA6cEATo5wOzUtg9XDn3kLgSkQfXMGWCIArD/NhCiRU7rbUFic5kd22oK+I8CS7v
O7dp1cyU1Aged1nO4TOwUsj/OcWFbM9CHXUKDqs5on42YrQakagViUi4i8Zi2P9i
JDxZIaNlLQsEz39imnXM70AMRXoPoOdxgZlIZz2Bxc+R/QT6eYyYC+NK8vjLuNGV
Jo7vjWlKWQ5UqlIyZQ1z7zl5sDvEXe/URXwXvnyKChsP23IW8H0KG0Wax0TZUU75
iqT2wd/0IfSQmpBzaX2G
=yYJn
-----END PGP SIGNATURE-----

--D3uGefx/nfj0hkMF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
