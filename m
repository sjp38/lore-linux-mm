Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD4856B0022
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:06:06 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u56so10419470wrf.18
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 10:06:06 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id h1si9313838wrc.271.2018.04.16.10.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 10:06:05 -0700 (PDT)
Date: Mon, 16 Apr 2018 19:06:04 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416170604.GC11034@amd>
References: <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm>
 <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home>
 <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home>
 <20180416161911.GA2341@sasha-vm>
 <20180416123019.4d235374@gandalf.local.home>
 <20180416163754.GD2341@sasha-vm>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="B4IIlcmfBL/1gGOG"
Content-Disposition: inline
In-Reply-To: <20180416163754.GD2341@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>


--B4IIlcmfBL/1gGOG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-04-16 16:37:56, Sasha Levin wrote:
> On Mon, Apr 16, 2018 at 12:30:19PM -0400, Steven Rostedt wrote:
> >On Mon, 16 Apr 2018 16:19:14 +0000
> >Sasha Levin <Alexander.Levin@microsoft.com> wrote:
> >
> >> >Wait! What does that mean? What's the purpose of stable if it is as
> >> >broken as mainline?
> >>
> >> This just means that if there is a fix that went in mainline, and the
> >> fix is broken somehow, we'd rather take the broken fix than not.
> >>
> >> In this scenario, *something* will be broken, it's just a matter of
> >> what. We'd rather have the same thing broken between mainline and
> >> stable.
> >
> >Honestly, I think that removes all value of the stable series. I
> >remember when the stable series were first created. People were saying
> >that it wouldn't even get to more than 5 versions, because the bar for
> >backporting was suppose to be very high. Today it's just a fork of the
> >kernel at a given version. No more features, but we will be OK with
> >regressions. I'm struggling to see what the benefit of it is suppose to
> >be?
>=20
> It's not "OK with regressions".
>=20
> Let's look at a hypothetical example: You have a 4.15.1 kernel that has
> a broken printf() behaviour so that when you:
>=20
> 	pr_err("%d", 5)
>=20
> Would print:
>=20
> 	"Microsoft Rulez"
>=20
> Bad, right? So you went ahead and fixed it, and now it prints "5" as you
> might expect. But alas, with your patch, running:
>=20
> 	pr_err("%s", "hi!")
>=20
> Would show a cat picture for 5 seconds.
>=20
> Should we take your patch in -stable or not? If we don't, we're stuck
> with the original issue while the mainline kernel will behave
> differently, but if we do - we introduce a new regression.

Of course not.

- It must be obviously correct and tested.

If it introduces new bug, it is not correct, and certainly not
obviously correct.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--B4IIlcmfBL/1gGOG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrU1/wACgkQMOfwapXb+vIjgQCdEVO1o/y2VmXGEcZZyPdYbKfc
GZoAn3Hi6VsBPbA2sH/ZU7m8YVz1KnWd
=jdee
-----END PGP SIGNATURE-----

--B4IIlcmfBL/1gGOG--
