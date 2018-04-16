Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3AC66B0012
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:00:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id m7so13589897wrb.16
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:00:12 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id u128si6114822wmu.87.2018.04.16.10.00.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 10:00:11 -0700 (PDT)
Date: Mon, 16 Apr 2018 19:00:10 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416170010.GA11034@amd>
References: <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd>
 <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm>
 <20180416122244.146aec48@gandalf.local.home>
 <20180416163107.GC2341@sasha-vm>
 <20180416124711.048f1858@gandalf.local.home>
 <20180416165258.GH2341@sasha-vm>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
In-Reply-To: <20180416165258.GH2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >> Let me ask my wife (who is happy using Linux as a regular desktop user)
> >> how comfortable she would be with triaging kernel bugs...
> >
> >That's really up to the distribution, not the main kernel stable. Does
> >she download and compile the kernels herself? Does she use LEDs?
> >
> >The point is, stable is to keep what was working continued working.
> >If we don't care about introducing a regression, and just want to keep
> >regressions the same as mainline, why not just go to mainline? That way
> >you can also get the new features? Mainline already has the mantra to
> >not break user space. When I work on new features, I sometimes stumble
> >on bugs with the current features. And some of those fixes require a
> >rewrite. It was "good enough" before, but every so often could cause a
> >bug that the new feature would trigger more often. Do we back port that
> >rewrite? Do we backport fixes to old code that are more likely to be
> >triggered by new features?
> >
> >Ideally, we should be working on getting to no regressions to stable.
>=20
> This is exactly what we're doing.
>=20
> If a fix for a bug in -stable introduces a different regression,
> should we take it or not?

If a fix for bug introduces regression, would you call it "obviously
correct"?

									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrU1poACgkQMOfwapXb+vKFVwCglrjm4215fTMbAYLHOx8MAtxa
bFwAnipr21zwvIMpsR6hS6lsLYQRnj+m
=wM9y
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
