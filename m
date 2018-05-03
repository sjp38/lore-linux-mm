Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91F8A6B0024
	for <linux-mm@kvack.org>; Thu,  3 May 2018 06:04:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i11-v6so11918847wre.16
        for <linux-mm@kvack.org>; Thu, 03 May 2018 03:04:43 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id p7-v6si1571450wrf.461.2018.05.03.03.04.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 03:04:42 -0700 (PDT)
Date: Thu, 3 May 2018 12:04:41 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180503100441.GE32180@amd>
References: <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
 <20180416211845.GP2341@sasha-vm>
 <nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm>
 <20180417103936.GC8445@kroah.com>
 <20180417110717.GB17484@dhcp22.suse.cz>
 <20180417140434.GU2341@sasha-vm>
 <20180417143631.GI17484@dhcp22.suse.cz>
 <20180417145531.GW2341@sasha-vm>
 <nycvar.YFH.7.76.1804171742450.28129@cbobk.fhfr.pm>
 <20180417160627.GX2341@sasha-vm>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zaRBsRFn0XYhEU69"
Content-Disposition: inline
In-Reply-To: <20180417160627.GX2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Jiri Kosina <jikos@kernel.org>, Michal Hocko <mhocko@kernel.org>, Greg KH <greg@kroah.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--zaRBsRFn0XYhEU69
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2018-04-17 16:06:29, Sasha Levin wrote:
> On Tue, Apr 17, 2018 at 05:52:30PM +0200, Jiri Kosina wrote:
> >On Tue, 17 Apr 2018, Sasha Levin wrote:
> >
> >> How do I get the XFS folks to send their stuff to -stable? (we have
> >> quite a few customers who use XFS)
> >
> >If XFS (or *any* other subsystem) doesn't have enough manpower of upstre=
am
> >maintainers to deal with stable, we just have to accept that and find an
> >answer to that.
>=20
> This is exactly what I'm doing. Many subsystems don't have enough
> manpower to deal with -stable, so I'm trying to help.

=2E..and the torrent of spams from the AUTOSEL subsystem actually makes
that worse.

And when you are told particular fix to LEDs is not that important
after all, you start arguing about nuclear power plants (without
really knowing how critical subsystems work).

If you want cooperation with maintainers to work, the rules need to be
clear, first. They are documented, so follow them. If you think rules
are wrong, lets talk about changing the rules; but arguing "every bug
is important because someone may be hitting it" is not ok.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--zaRBsRFn0XYhEU69
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrq3rkACgkQMOfwapXb+vL3WgCePfWMg7iZHBhdexYMSWCmEBeL
m0QAoJ423IJ5qO/X0Qh+fM867kCxABvz
=7e2E
-----END PGP SIGNATURE-----

--zaRBsRFn0XYhEU69--
