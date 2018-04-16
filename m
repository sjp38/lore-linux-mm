Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B58206B0268
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:06:11 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o8so13085783wra.12
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:06:11 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id h33si9519538wrh.374.2018.04.16.09.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:06:10 -0700 (PDT)
Date: Mon, 16 Apr 2018 18:06:08 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416160608.GA7071@amd>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd>
 <20180416155031.GX2341@sasha-vm>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1yeeQ81UyVL57Vl7"
Content-Disposition: inline
In-Reply-To: <20180416155031.GX2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-04-16 15:50:34, Sasha Levin wrote:
> On Mon, Apr 16, 2018 at 05:30:31PM +0200, Pavel Machek wrote:
> >On Mon 2018-04-16 08:18:09, Linus Torvalds wrote:
> >> On Mon, Apr 16, 2018 at 6:30 AM, Steven Rostedt <rostedt@goodmis.org> =
wrote:
> >> >
> >> > I wonder if the "AUTOSEL" patches should at least have an "ack-by" f=
rom
> >> > someone before they are pulled in. Otherwise there may be some subtle
> >> > issues that can find their way into stable releases.
> >>
> >> I don't know about anybody else, but I  get so many of the patch-bot
> >> patches for stable etc that I will *not* reply to normal cases. Only
> >> if there's some issue with a patch will I reply.
> >>
> >> I probably do get more than most, but still - requiring active
> >> participation for the steady flow of normal stable patches is almost
> >> pointless.
> >>
> >> Just look at the subject line of this thread. The numbers are so big
> >> that you almost need exponential notation for them.
> >
> >Question is if we need that many stable patches? Autosel seems to be
> >picking up race conditions in LED state and W+X page fixes... I'd
> >really like to see less stable patches.
>=20
> Why? Given that the kernel keeps seeing more and more lines of code in
> each new release, tools around the kernel keep evolving (new fuzzers,
> testing suites, etc), and code gets more eyes, this guarantees that
> you'll see more and more stable patches for each release as well.
>=20
> Is there a reason not to take LED fixes if they fix a bug and don't
> cause a regression? Sure, we can draw some arbitrary line, maybe
> designate some subsystems that are more "important" than others, but
> what's the point?

There's a tradeoff.

You want to fix serious bugs in stable, and you really don't want
regressions in stable. And ... stable not having 1000s of patches
would be nice, too.

That means you want to ignore not-so-serious bugs, because benefit of
fixing them is lower than risk of the regressions. I believe bugs that
do not bother anyone should _not_ be fixed in stable.

That was case of the LED patch. Yes, the commit fixed bug, but it
introduced regressions that were fixed by subsequent patches.

								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--1yeeQ81UyVL57Vl7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrUyfAACgkQMOfwapXb+vLqUACgrZVT5d1bgIPh6zWw8qPcYOP8
AxQAoLGANdVBhlKdNdoj4a7b8DIFJWeV
=hxVk
-----END PGP SIGNATURE-----

--1yeeQ81UyVL57Vl7--
