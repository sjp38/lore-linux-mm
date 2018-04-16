Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DABF6B000A
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:42:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z7so3020287wrg.11
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:42:33 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id g14si9256830wrh.54.2018.04.16.09.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:42:32 -0700 (PDT)
Date: Mon, 16 Apr 2018 18:42:30 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416164230.GA9807@amd>
References: <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd>
 <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm>
 <20180416162850.GA7553@amd>
 <20180416163917.GE2341@sasha-vm>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
In-Reply-To: <20180416163917.GE2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-04-16 16:39:20, Sasha Levin wrote:
> On Mon, Apr 16, 2018 at 06:28:50PM +0200, Pavel Machek wrote:
> >
> >> >> Is there a reason not to take LED fixes if they fix a bug and don't
> >> >> cause a regression? Sure, we can draw some arbitrary line, maybe
> >> >> designate some subsystems that are more "important" than others, but
> >> >> what's the point?
> >> >
> >> >There's a tradeoff.
> >> >
> >> >You want to fix serious bugs in stable, and you really don't want
> >> >regressions in stable. And ... stable not having 1000s of patches
> >> >would be nice, too.
> >>
> >> I don't think we should use a number cap here, but rather look at the
> >> regression rate: how many patches broke something?
> >>
> >> Since the rate we're seeing now with AUTOSEL is similar to what we were
> >> seeing before AUTOSEL, what's the problem it's causing?
> >
> >Regression rate should not be the only criteria.
> >
> >More patches mean bigger chance customer's patches will have a
> >conflict with something in -stable, for example.
>=20
> Out of tree patches can't be a consideration here. There are no
> guarantees for out of tree code, ever.

Out of tree code is not consideration for mainline, agreed. Stable
should be different.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--AqsLC8rIMeq19msA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrU0nYACgkQMOfwapXb+vK4LwCgiKi4ndB8QkImv8i+2CnZOiN8
xWsAn2jvJu/AuyU9cIwgMG0CPbq8xRWF
=Xc7g
-----END PGP SIGNATURE-----

--AqsLC8rIMeq19msA--
