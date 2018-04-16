Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A37076B026E
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:10:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i4so13603681wrh.4
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:10:18 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id j20si4979855wme.167.2018.04.16.09.10.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:10:17 -0700 (PDT)
Date: Mon, 16 Apr 2018 18:10:15 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416161015.GB7071@amd>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home>
 <20180416160200.GY2341@sasha-vm>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rS8CxjVDS/+yyDmU"
Content-Disposition: inline
In-Reply-To: <20180416160200.GY2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--rS8CxjVDS/+yyDmU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-04-16 16:02:03, Sasha Levin wrote:
> On Mon, Apr 16, 2018 at 11:36:29AM -0400, Steven Rostedt wrote:
> >On Mon, 16 Apr 2018 08:18:09 -0700
> >Linus Torvalds <torvalds@linux-foundation.org> wrote:
> >
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
> >>
> >
> >I'm worried about just backporting patches that nobody actually looked
> >at. Is someone going through and vetting that these should definitely
> >be added to stable. I would like to have some trusted human (doesn't
> >even need to be the author or maintainer of the patch) to look at all
> >the patches before they are applied.
>=20
> I do go through every single commit sent this way and review it.
> Sometimes things slip by, but it's not a fully automatic process.
>=20
> Let's look at this patch as a concrete example: the only reason,
> according to the stable rules, that it shouldn't go in -stable is that
> it's longer than 100 lines.
>=20
> Otherwise, it fixes a bug, it doesn't introduce any new features, it's
> upstream, and so on. It had some fixes that went upstream as well?
> Great, let's grab those as well.
>=20
> >I would say anything more than a trivial patch would require author or
> >sub maintainer ack. Look at this patch, I don't think it should go to
> >stable, even though it does fix issues. But the fix is for systems
> >already having issues, and this keeps printk from making things worse.
> >The fix has side effects that other commits have addressed, and if this
> >patch gets backported, those other ones must too.
>=20
> Sure, let's get those patches in as well.
>=20
> One of the things Greg is pushing strongly for is "bug compatibility":
> we want the kernel to behave the same way between mainline and stable.
> If the code is broken, it should be broken in the same way.

Maybe Greg should be Cced on this conversation?

Anyway, I don't think "bug compatibility" is a good goal.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--rS8CxjVDS/+yyDmU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrUyucACgkQMOfwapXb+vKsLgCgkBwiBshOxVG9qEz4hcJr4E+h
RBIAniyDsb9f2LcoUr2MS3ZSknJRu5gK
=WpRw
-----END PGP SIGNATURE-----

--rS8CxjVDS/+yyDmU--
