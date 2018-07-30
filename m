Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68C656B0006
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 13:39:43 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id a9-v6so10349473wrw.20
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:39:43 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id 1-v6si2475962wrh.317.2018.07.30.10.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 10:39:42 -0700 (PDT)
Date: Mon, 30 Jul 2018 19:39:40 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180730173940.GB881@amd>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180727220123.GB18879@amd>
 <20180730154035.GC4567@cmpxchg.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0eh6TmSyL6TZE2Uz"
Content-Disposition: inline
In-Reply-To: <20180730154035.GC4567@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


--0eh6TmSyL6TZE2Uz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-07-30 11:40:35, Johannes Weiner wrote:
> On Sat, Jul 28, 2018 at 12:01:23AM +0200, Pavel Machek wrote:
> > > 		How do you use this feature?
> > >=20
> > > A kernel with CONFIG_PSI=3Dy will create a /proc/pressure directory w=
ith
> > > 3 files: cpu, memory, and io. If using cgroup2, cgroups will also
> >=20
> > Could we get the config named CONFIG_PRESSURE to match /proc/pressure?
> > "PSI" is little too terse...
>=20
> I'd rather have the internal config symbol match the naming scheme in
> the code, where psi is a shorter, unique token as copmared to e.g.
> pressure, press, prsr, etc.

I'd do "pressure", really. Yes, psi is shorter, but I'd say that
length is not really important there.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--0eh6TmSyL6TZE2Uz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltfTVwACgkQMOfwapXb+vIlkgCeK9KRUnDyKNk7tez2Mpwtukiw
uAMAn0ZpVKvSol9WKtgbznn5hShpYu+b
=iFrT
-----END PGP SIGNATURE-----

--0eh6TmSyL6TZE2Uz--
