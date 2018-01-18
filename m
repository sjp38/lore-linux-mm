Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A78346B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:03:27 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r63so10096wmb.9
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 14:03:27 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id l58si6827038wrl.33.2018.01.18.14.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 14:03:25 -0800 (PST)
Date: Thu, 18 Jan 2018 23:03:24 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to
 load balance console writes
Message-ID: <20180118220323.GC17196@amd>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <20180112115454.17c03c8f@gandalf.local.home>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0vzXIDBeUiKkjNJl"
Content-Disposition: inline
In-Reply-To: <20180112115454.17c03c8f@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org


--0vzXIDBeUiKkjNJl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > By other words, this deadlock was there even before. Such
> > deadlocks are prevented by using printk_deferred() in
> > the sections guarded by the lock A.
>=20
> Petr,
>=20
> Please add this here:
>=20
> =3D=3D=3D=3D
>=20
> To demonstrate the issue, this module has been shown to lock up a
> system with 4 CPUs and a slow console (like a serial console). It is
> also able to lock up a 8 CPU system with only a fast (VGA) console, by
> passing in "loops=3D100". The changes in this commit prevent this module
> from locking up the system.
>=20
> #include <linux/module.h>
> #include <linux/delay.h>
> #include <linux/sched.h>
> #include <linux/mutex.h>
> #include <linux/workqueue.h>
> #include <linux/hrtimer.h>

Programs in commit messages. Not preffered way to distribute code, I'd
say. What about putting it into kernel selftests directory or
something like that?
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--0vzXIDBeUiKkjNJl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlphGasACgkQMOfwapXb+vLGWgCguDUXPlJK0TKjbQ47MUhvfKzb
dB4AoKe/lH5K/FrGw3K3FS0jUtit0GxQ
=jEBq
-----END PGP SIGNATURE-----

--0vzXIDBeUiKkjNJl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
