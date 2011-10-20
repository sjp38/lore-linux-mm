Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7A36B0035
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 02:30:32 -0400 (EDT)
From: =?utf-8?q?Pawe=C5=82_Sikora?= <pluto@agmk.net>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Date: Thu, 20 Oct 2011 08:30:21 +0200
References: <201110122012.33767.pluto@agmk.net> <CA+55aFwf75oJ3JJ2aCR8TJJm_oLireD6SDO+43GveVVb8vGw1w@mail.gmail.com> <alpine.LSU.2.00.1110191234570.6900@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1110191234570.6900@sister.anvils>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <201110200830.22062.pluto@agmk.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Wednesday 19 of October 2011 21:42:15 Hugh Dickins wrote:
> On Wed, 19 Oct 2011, Linus Torvalds wrote:
> > On Wed, Oct 19, 2011 at 12:43 AM, Mel Gorman <mgorman@suse.de> wrote:
> > >
> > > My vote is with the migration change. While there are occasionally
> > > patches to make migration go faster, I don't consider it a hot path.
> > > mremap may be used intensively by JVMs so I'd loathe to hurt it.
> > 
> > Ok, everybody seems to like that more, and it removes code rather than
> > adds it, so I certainly prefer it too. Pawel, can you test that other
> > patch (to mm/migrate.c) that Hugh posted? Instead of the mremap vma
> > locking patch that you already verified for your setup?
> > 
> > Hugh - that one didn't have a changelog/sign-off, so if you could
> > write that up, and Pawel's testing is successful, I can apply it...
> > Looks like we have acks from both Andrea and Mel.
> 
> Yes, I'm glad to have that input from Andrea and Mel, thank you.
> 
> Here we go.  I can't add a Tested-by since Pawel was reporting on the
> alternative patch, but perhaps you'll be able to add that in later.
> 
> I may have read too much into Pawel's mail, but it sounded like he
> would have expected an eponymous find_get_pages() lockup by now,
> and was pleased that this patch appeared to have cured that.
> 
> I've spent quite a while trying to explain find_get_pages() lockup by
> a missed migration entry, but I just don't see it: I don't expect this
> (or the alternative) patch to do anything to fix that problem.  I won't
> mind if it magically goes away, but I expect we'll need more info from
> the debug patch I sent Justin a couple of days ago.

the latest patch (mm/migrate.c) applied on 3.0.4 also survives points
1) and 2) described previously (https://lkml.org/lkml/2011/10/18/427),
so please apply it to the upstream/stable git tree.

from the other side, both patches don't help for 3.0.4+vserver host soft-lock
which dies in few hours of stressing. iirc this lock has started with 2.6.38.
is there any major change in memory managment area in 2.6.38 that i can bisect
and test with vserver?

BR,
PaweA?.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
