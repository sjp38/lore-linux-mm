Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64B336B0286
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:30:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z7so2802460wrg.11
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:30:34 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id t80si691305wrc.72.2018.04.16.08.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:30:33 -0700 (PDT)
Date: Mon, 16 Apr 2018 17:30:31 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416153031.GA5039@amd>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
Content-Disposition: inline
In-Reply-To: <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sasha Levin <Alexander.Levin@microsoft.com>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-04-16 08:18:09, Linus Torvalds wrote:
> On Mon, Apr 16, 2018 at 6:30 AM, Steven Rostedt <rostedt@goodmis.org> wro=
te:
> >
> > I wonder if the "AUTOSEL" patches should at least have an "ack-by" from
> > someone before they are pulled in. Otherwise there may be some subtle
> > issues that can find their way into stable releases.
>=20
> I don't know about anybody else, but I  get so many of the patch-bot
> patches for stable etc that I will *not* reply to normal cases. Only
> if there's some issue with a patch will I reply.
>=20
> I probably do get more than most, but still - requiring active
> participation for the steady flow of normal stable patches is almost
> pointless.
>=20
> Just look at the subject line of this thread. The numbers are so big
> that you almost need exponential notation for them.

Question is if we need that many stable patches? Autosel seems to be
picking up race conditions in LED state and W+X page fixes... I'd
really like to see less stable patches.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--huq684BweRXVnRxX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrUwZcACgkQMOfwapXb+vLyugCeOGD9Ww5IgWnSxK5d1h1gXSkk
t8YAnjd3az8WOw1SK0e59lD4Pm85BLVw
=4wFd
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
