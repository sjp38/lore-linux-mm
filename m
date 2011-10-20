Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BAA9F6B0037
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 02:51:35 -0400 (EDT)
Received: by wwf5 with SMTP id 5so3033018wwf.26
        for <linux-mm@kvack.org>; Wed, 19 Oct 2011 23:51:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201110200830.22062.pluto@agmk.net>
References: <201110122012.33767.pluto@agmk.net> <CA+55aFwf75oJ3JJ2aCR8TJJm_oLireD6SDO+43GveVVb8vGw1w@mail.gmail.com>
 <alpine.LSU.2.00.1110191234570.6900@sister.anvils> <201110200830.22062.pluto@agmk.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 19 Oct 2011 23:51:11 -0700
Message-ID: <CA+55aFwU-xwg=5ZDqsA1xwKsjeTT=8uDRygCJoW1ya7-QBitSw@mail.gmail.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-2?Q?Pawe=B3_Sikora?= <pluto@agmk.net>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

2011/10/19 Pawe=C5=82 Sikora <pluto@agmk.net>:
>
> the latest patch (mm/migrate.c) applied on 3.0.4 also survives points
> 1) and 2) described previously (https://lkml.org/lkml/2011/10/18/427),
> so please apply it to the upstream/stable git tree.

Ok, thanks, applied and pushed out.

> from the other side, both patches don't help for 3.0.4+vserver host soft-=
lock
> which dies in few hours of stressing. iirc this lock has started with 2.6=
.38.
> is there any major change in memory managment area in 2.6.38 that i can b=
isect
> and test with vserver?

I suspect you'd be best off simply just doing a full bisect. Yes, if
2.6.37 is the last known working kernel for you, and 38 breaks, that's
a lot of commits (about 10k, to be exact), and it will take an
annoying number of reboots and tests, but assuming you don't hit any
problems, it should still be "only" about 14 bisection points or so.

You could *try* to minimize the bisect by only looking at commits that
change mm/, but quite frankly, partial tree bisects tend to not be all
that reliable. But if you want to try, you could do basically

   git bisect start mm/
   git bisect good v2.6.37
   git bisect bad v2.6.38

and go from there. That will try to do a more specific bisect, and you
should have fewer test points, but the end result really is much less
reliable. But it might help narrow things down a bit.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
