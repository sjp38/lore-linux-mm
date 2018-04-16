Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20EC96B0012
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:59:00 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d15so4862463wra.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:59:00 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id q190si6159254wmd.208.2018.04.16.09.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:58:59 -0700 (PDT)
Date: Mon, 16 Apr 2018 18:58:57 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416165857.GC9807@amd>
References: <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416153031.GA5039@amd>
 <20180416155031.GX2341@sasha-vm>
 <20180416160608.GA7071@amd>
 <20180416122019.1c175925@gandalf.local.home>
 <20180416162757.GB2341@sasha-vm>
 <20180416163952.GA8740@amd>
 <20180416164310.GF2341@sasha-vm>
 <20180416125307.0c4f6f28@gandalf.local.home>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NKoe5XOeduwbEQHU"
Content-Disposition: inline
In-Reply-To: <20180416125307.0c4f6f28@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>


--NKoe5XOeduwbEQHU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-04-16 12:53:07, Steven Rostedt wrote:
> On Mon, 16 Apr 2018 16:43:13 +0000
> Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>=20
> > >If you are worried about people not putting enough "Stable: " tags in
> > >their commits, perhaps you can write them emails "hey, I think this
> > >should go to stable, do you agree"? You should get people marking
> > >their commits themselves pretty quickly... =20
> >=20
> > Greg has been doing this for years, ask him how that worked out for him.
>=20
> Then he shouldn't pull in the fix. Let it be broken. As soon as someone
> complains about it being broken, then bug the maintainer again. "Hey,
> this is broken in 4.x, and this looks like the fix for it. Do you
> agree?"
>=20
> I agree that some patches don't need this discussion. Things that are
> obvious. Off-by-one and stack-overflow and other bugs like that. Or
> another common bug is error paths that don't release locks. These
> should just be backported. But subtle fixes like this thread should
> default to (not backport unless someones complains or the
> author/maintainer acks it).

Agreed. And it scares me we are even discussing this.


									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--NKoe5XOeduwbEQHU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlrU1lEACgkQMOfwapXb+vLbpACgiQyEJcGYB3C8JRLh9fzRBOui
GUkAoJ6z5s4gm1VYxIloiLVXJnqKaDJe
=vmwF
-----END PGP SIGNATURE-----

--NKoe5XOeduwbEQHU--
