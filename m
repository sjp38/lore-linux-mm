Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63D3C6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:54:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b10so2203888wrf.3
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:54:54 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id b97si8876987wrd.260.2018.04.16.09.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:54:53 -0700 (PDT)
Date: Mon, 16 Apr 2018 18:54:51 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416165451.GB9807@amd>
References: <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd>
 <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm>
 <20180416162850.GA7553@amd>
 <20180416163917.GE2341@sasha-vm>
 <20180416164230.GA9807@amd>
 <20180416164514.GG2341@sasha-vm>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VrqPEDrXMn8OVzN4"
Content-Disposition: inline
In-Reply-To: <20180416164514.GG2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--VrqPEDrXMn8OVzN4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-04-16 16:45:16, Sasha Levin wrote:
> On Mon, Apr 16, 2018 at 06:42:30PM +0200, Pavel Machek wrote:
> >On Mon 2018-04-16 16:39:20, Sasha Levin wrote:
> >> On Mon, Apr 16, 2018 at 06:28:50PM +0200, Pavel Machek wrote:
> >> >
> >> >> >> Is there a reason not to take LED fixes if they fix a bug and do=
n't
> >> >> >> cause a regression? Sure, we can draw some arbitrary line, maybe
> >> >> >> designate some subsystems that are more "important" than others,=
 but
> >> >> >> what's the point?
> >> >> >
> >> >> >There's a tradeoff.
> >> >> >
> >> >> >You want to fix serious bugs in stable, and you really don't want
> >> >> >regressions in stable. And ... stable not having 1000s of patches
> >> >> >would be nice, too.
> >> >>
> >> >> I don't think we should use a number cap here, but rather look at t=
he
> >> >> regression rate: how many patches broke something?
> >> >>
> >> >> Since the rate we're seeing now with AUTOSEL is similar to what we =
were
> >> >> seeing before AUTOSEL, what's the problem it's causing?
> >> >
> >> >Regression rate should not be the only criteria.
> >> >
> >> >More patches mean bigger chance customer's patches will have a
> >> >conflict with something in -stable, for example.
> >>
> >> Out of tree patches can't be a consideration here. There are no
> >> guarantees for out of tree code, ever.
> >
> >Out of tree code is not consideration for mainline, agreed. Stable
> >should be different.
>=20
> This is a discussion we could have with in right forum, but FYI stable
> doesn't even guarantee KABI compatibility between minor versions at this
> point.

Stable should be useful base for distributions. They carry out of tree
patches, and yes, you should try to make their lives easy.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--VrqPEDrXMn8OVzN4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrU1VsACgkQMOfwapXb+vLrpACfZfYG+++ePuNgKiIufAF8pCZk
cXAAn217Ofaj72rXdJQjIhhz7la4TSsT
=YGfb
-----END PGP SIGNATURE-----

--VrqPEDrXMn8OVzN4--
