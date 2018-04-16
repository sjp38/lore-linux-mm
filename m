Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 207216B000A
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:39:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p4so13395405wrf.17
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:39:56 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id k67si6383579wmd.198.2018.04.16.09.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:39:55 -0700 (PDT)
Date: Mon, 16 Apr 2018 18:39:53 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416163952.GA8740@amd>
References: <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd>
 <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
 <20180416122019.1c175925@gandalf.local.home>
 <20180416162757.GB2341@sasha-vm>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="envbJBWh7q8WU6mo"
Content-Disposition: inline
In-Reply-To: <20180416162757.GB2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-04-16 16:28:00, Sasha Levin wrote:
> On Mon, Apr 16, 2018 at 12:20:19PM -0400, Steven Rostedt wrote:
> >On Mon, 16 Apr 2018 18:06:08 +0200
> >Pavel Machek <pavel@ucw.cz> wrote:
> >
> >> That means you want to ignore not-so-serious bugs, because benefit of
> >> fixing them is lower than risk of the regressions. I believe bugs that
> >> do not bother anyone should _not_ be fixed in stable.
> >>
> >> That was case of the LED patch. Yes, the commit fixed bug, but it
> >> introduced regressions that were fixed by subsequent patches.
> >
> >I agree. I would disagree that the patch this thread is on should go to
> >stable. What's the point of stable if it introduces regressions by
> >backporting bug fixes for non major bugs.
>=20
> One such reason is that users will then hit the regression when they
> upgrade to the next -stable version anyways.

Well, yes, testing is required when moving from 4.14 to 4.15. But
testing should not be required when moving from 4.14.5 to 4.14.6.

> >Every fix I make I consider labeling it for stable. The ones I don't, I
> >feel the bug fix is not worth the risk of added regressions.
> >
> >I worry that people will get lazy and stop marking commits for stable
> >(or even thinking about it) because they know that there's a bot that
> >will pull it for them. That thought crossed my mind. Why do I want to
> >label anything stable if a bot will probably catch it. Then I could
> >just wait till the bot posts it before I even think about stable.
>=20
> People are already "lazy". You are actually an exception for marking your
> commits.
>=20
> Yes, folks will chime in with "sure, I mark my patches too!", but if you
> look at the entire committer pool in the kernel you'll see that most
> don't bother with this to begin with.

So you take everything and put it into stable? I don't think that's a
solution.

If you are worried about people not putting enough "Stable: " tags in
their commits, perhaps you can write them emails "hey, I think this
should go to stable, do you agree"? You should get people marking
their commits themselves pretty quickly...
								=09
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--envbJBWh7q8WU6mo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrU0dgACgkQMOfwapXb+vKZNQCffEDUMR9dsaiM6OWcxujTun0x
yFwAmwQdBZnRo/K55M/VNiSnmOOKXC9H
=ZOmi
-----END PGP SIGNATURE-----

--envbJBWh7q8WU6mo--
