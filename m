Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 723B46B0010
	for <linux-mm@kvack.org>; Thu,  3 May 2018 05:36:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k16-v6so11864815wrh.6
        for <linux-mm@kvack.org>; Thu, 03 May 2018 02:36:53 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id 11si6334520wmj.119.2018.05.03.02.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 02:36:52 -0700 (PDT)
Date: Thu, 3 May 2018 11:36:51 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180503093651.GC32180@amd>
References: <20180416121224.2138b806@gandalf.local.home>
 <20180416161911.GA2341@sasha-vm>
 <20180416123019.4d235374@gandalf.local.home>
 <20180416163754.GD2341@sasha-vm>
 <20180416170604.GC11034@amd>
 <20180416172327.GK2341@sasha-vm>
 <20180417114144.ov27khlig5thqvyo@quack2.suse.cz>
 <20180417133149.GR2341@sasha-vm>
 <20180417155549.6lxmoiwnlwtwdgld@quack2.suse.cz>
 <20180417161933.GY2341@sasha-vm>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lMM8JwqTlfDpEaS6"
Content-Disposition: inline
In-Reply-To: <20180417161933.GY2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>, jacek.anaszewski@gmail.com, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Jan Kara <jack@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--lMM8JwqTlfDpEaS6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2018-04-17 16:19:35, Sasha Levin wrote:
> On Tue, Apr 17, 2018 at 05:55:49PM +0200, Jan Kara wrote:
> >On Tue 17-04-18 13:31:51, Sasha Levin wrote:
> >> We may be able to guesstimate the 'regression chance', but there's no
> >> way we can guess the 'annoyance' once. There are so many different use
> >> cases that we just can't even guess how many people would get "annoyed"
> >> by something.
> >
> >As a maintainer, I hope I have reasonable idea what are common use cases
> >for my subsystem. Those I cater to when estimating 'annoyance'. Sure I d=
on't
> >know all of the use cases so people doing unusual stuff hit more bugs and
> >have to report them to get fixes included in -stable. But for me this is=
 a
> >preferable tradeoff over the risk of regression so this is the rule I use
> >when tagging for stable. Now I'm not a -stable maintainer and I fully ag=
ree
> >with "those who do the work decide" principle so pick whatever patches y=
ou
> >think are appropriate, I just wanted explain why I don't think more patc=
hes
> >in stable are necessarily good.
>=20
> The AUTOSEL story is different for subsystems that don't do -stable, and
> subsystems that are actually doing the work (like yourself).
>=20
> I'm not trying to override active maintainers, I'm trying to help them
> make decisions.

Ok, cool. Can you exclude LED subsystem, Hibernation and Nokia N900
stuff from autosel work?

									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--lMM8JwqTlfDpEaS6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrq2DMACgkQMOfwapXb+vJbHQCfeKHDBJ7/Bf+FhvuYHI5f0JHr
dV8AnRA7YSWoh8YJe0eze3ZDbiDSrv/C
=0tUe
-----END PGP SIGNATURE-----

--lMM8JwqTlfDpEaS6--
