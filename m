Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id E042C6B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 22:11:05 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id gi9so7726720lab.38
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 19:11:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pk5si16604369lbb.60.2014.09.22.19.11.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 19:11:03 -0700 (PDT)
Date: Tue, 23 Sep 2014 12:10:52 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 1/4] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-ID: <20140923121052.55dcb4f5@notabene.brown>
In-Reply-To: <20140918144222.GP2840@worktop.localdomain>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916053134.22257.28841.stgit@notabene.brown>
	<20140918144222.GP2840@worktop.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/p0YjgUNWIN4ITSBXs16hgVq"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>

--Sig_/p0YjgUNWIN4ITSBXs16hgVq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 18 Sep 2014 16:42:22 +0200 Peter Zijlstra <peterz@infradead.org>
wrote:

> On Tue, Sep 16, 2014 at 03:31:35PM +1000, NeilBrown wrote:
> > In commit c1221321b7c25b53204447cff9949a6d5a7ddddc
> >    sched: Allow wait_on_bit_action() functions to support a timeout
> >=20
> > I suggested that a "wait_on_bit_timeout()" interface would not meet my
> > need.  This isn't true - I was just over-engineering.
> >=20
> > Including a 'private' field in wait_bit_key instead of a focused
> > "timeout" field was just premature generalization.  If some other
> > use is ever found, it can be generalized or added later.
> >=20
> > So this patch renames "private" to "timeout" with a meaning "stop
> > waiting when "jiffies" reaches or passes "timeout",
> > and adds two of the many possible wait..bit..timeout() interfaces:
> >=20
> > wait_on_page_bit_killable_timeout(), which is the one I want to use,
> > and out_of_line_wait_on_bit_timeout() which is a reasonably general
> > example.  Others can be added as needed.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  include/linux/pagemap.h |    2 ++
> >  include/linux/wait.h    |    5 ++++-
> >  kernel/sched/wait.c     |   36 ++++++++++++++++++++++++++++++++++++
> >  mm/filemap.c            |   13 +++++++++++++
> >  4 files changed, 55 insertions(+), 1 deletion(-)
> >=20
>=20
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Thanks.
I assume that means it is OK for this patch to go to Linus via the NFS tree,
so we get to keep everything together.
Now I just need an Ack from akpm for the mm bits (please...)

NeilBrown

--Sig_/p0YjgUNWIN4ITSBXs16hgVq
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCDWrDnsnt1WYoG5AQKsuQ/9HIaWXs87B636Ar7UMkB6HHUl9gMQjcoP
11l6Kq3jn0x+mJYXV/eMCLHrOYpsJsfFph0YVq/40CW5PNw/rY5V+/LAd6AQ0TXJ
0Sb7GFbUzBO3LaaYppoFfBipS+IflfIY5YcOZqqHPZJ1kdozWb4t+0jWlyJ+l2mz
M3o0ikklWQDA1Q187HskpadlG7sJx7B2NrzM0aJHVOAjcSjfFdCyxdE/hVxZ+bvO
9ZvQV3p4krgsr4ofIfIkVC3jJO96p/HJLC/tQkgUuWeSJ8Com1pRNxC6AdpMmxCf
/xhLaBnek3jRVLr9xfVUbHccywdMMfZz0NH+60TbR1WWAiTeLTYZ/VDXVqLaRRQJ
QvuC3Q+he3766V55xvlns9xJGeaAXnSwQxiIxoMGRe5HxSIJU9Z+br58UnEkkhzy
Sk4CwbcEcbN0510UQeGZeiQ9R1haxr02dMRUjjbOTxHo3RK0x4iVLAVp63dotjwF
Xi4VcW6bc2ujkbYt+lJRnxvvUSxHqLlc45YzbDZFi3K8EzW+A//yed+OcQ/L61Ju
q1maA1eE2G08Qss39ZpH/kws6LGQA8AH649vqqJoBtbbKCQ13238IwTBzGJkgeXs
J7JQ7yV10S2glLZCrSADTbRJGSE4Ps48FiWbgaWLmrcZ5L8yuiPf3ORmSPPjIrzo
NW5R+XPbNO4=
=YiXD
-----END PGP SIGNATURE-----

--Sig_/p0YjgUNWIN4ITSBXs16hgVq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
