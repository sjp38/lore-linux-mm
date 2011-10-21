Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EC6256B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 03:36:00 -0400 (EDT)
From: Pawel Sikora <pluto@agmk.net>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Date: Fri, 21 Oct 2011 09:35:46 +0200
Message-ID: <2082417.IAMpsykX5y@pawels>
In-Reply-To: <CAPQyPG5c1ADteP_rA2JRqLz88s7ZP_vWAKV-dp2hCSM9bRCpmg@mail.gmail.com>
References: <201110122012.33767.pluto@agmk.net> <201110200830.22062.pluto@agmk.net> <CAPQyPG5c1ADteP_rA2JRqLz88s7ZP_vWAKV-dp2hCSM9bRCpmg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Friday 21 of October 2011 14:54:29 Nai Xia wrote:
> 2011/10/20 Pawe=C5=82 Sikora <pluto@agmk.net>:
> > On Wednesday 19 of October 2011 21:42:15 Hugh Dickins wrote:
> >> On Wed, 19 Oct 2011, Linus Torvalds wrote:
> >> > On Wed, Oct 19, 2011 at 12:43 AM, Mel Gorman <mgorman@suse.de> w=
rote:
> >> > >
> >> > > My vote is with the migration change. While there are occasion=
ally
> >> > > patches to make migration go faster, I don't consider it a hot=
 path.
> >> > > mremap may be used intensively by JVMs so I'd loathe to hurt i=
t.
> >> >
> >> > Ok, everybody seems to like that more, and it removes code rathe=
r than
> >> > adds it, so I certainly prefer it too. Pawel, can you test that =
other
> >> > patch (to mm/migrate.c) that Hugh posted? Instead of the mremap =
vma
> >> > locking patch that you already verified for your setup?
> >> >
> >> > Hugh - that one didn't have a changelog/sign-off, so if you coul=
d
> >> > write that up, and Pawel's testing is successful, I can apply it=
...
> >> > Looks like we have acks from both Andrea and Mel.
> >>
> >> Yes, I'm glad to have that input from Andrea and Mel, thank you.
> >>
> >> Here we go.  I can't add a Tested-by since Pawel was reporting on =
the
> >> alternative patch, but perhaps you'll be able to add that in later=
.
> >>
> >> I may have read too much into Pawel's mail, but it sounded like he=

> >> would have expected an eponymous find_get_pages() lockup by now,
> >> and was pleased that this patch appeared to have cured that.
> >>
> >> I've spent quite a while trying to explain find_get_pages() lockup=
 by
> >> a missed migration entry, but I just don't see it: I don't expect =
this
> >> (or the alternative) patch to do anything to fix that problem.  I =
won't
> >> mind if it magically goes away, but I expect we'll need more info =
from
> >> the debug patch I sent Justin a couple of days ago.
> >
> > the latest patch (mm/migrate.c) applied on 3.0.4 also survives poin=
ts
> > 1) and 2) described previously (https://lkml.org/lkml/2011/10/18/42=
7),
> > so please apply it to the upstream/stable git tree.
> >
> > from the other side, both patches don't help for 3.0.4+vserver host=
 soft-lock
>=20
> Hi Pawe=C5=82,
>=20
> Did your "both" mean that you applied each patch and run the tests se=
parately,

yes, i've tested Hugh's patches separately.

> Maybe there were more than one bugs dancing but having a same effect,=

> not fixing all of them wouldn't help at all.

i suppose that vserver patch only exposes some tricky bug introduced in=
 2.6.38.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
