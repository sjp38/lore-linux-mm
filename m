Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB4C8D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 16:25:30 -0500 (EST)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: hunting an IO hang
In-reply-to: <AANLkTi=V1si-+UgmLD+YFzn5cf-x8q=tV_JhHisQUV7z@mail.gmail.com>
References: <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com> <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com> <1295229722-sup-6494@think> <20110116183000.cc632557.akpm@linux-foundation.org> <1295231547-sup-8036@think> <20110117102744.GA27152@csn.ul.ie> <1295269009-sup-7646@think> <20110117135059.GB27152@csn.ul.ie> <1295272970-sup-6500@think> <1295276272-sup-1788@think> <20110117170907.GC27152@csn.ul.ie> <1295285676-sup-8962@think> <AANLkTi=V1si-+UgmLD+YFzn5cf-x8q=tV_JhHisQUV7z@mail.gmail.com>
Date: Mon, 17 Jan 2011 16:23:56 -0500
Message-Id: <1295298806-sup-2802@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Excerpts from Linus Torvalds's message of 2011-01-17 13:24:55 -0500:
> On Mon, Jan 17, 2011 at 9:40 AM, Chris Mason <chris.mason@oracle.com> wrote:
> >> >
> >> > I've reverted 744ed1442757767ffede5008bb13e0805085902e, and
> >> > d8505dee1a87b8d41b9c4ee1325cd72258226fbc and the run has lasted longer
> >> > than any runs in the past.
> >> >
> >>
> >> Confirmed that reverting these patches makes the problem unreproducible
> >> for the many_dd's + fsmark for at least an hour here.
> >
> > After 2+ hours I'm still running with those two commits gone. A I'm
> > confident they are the cause of the crashes. A I also haven't triggered
> > the cfq stalls without them.
> 
> Ok, so the question is how to proceed from here.
> 
> I can easily revert them, and since I was planning on doing -rc1
> tonight, I probably will. But I promised Chris to delay until tomorrow
> if he needed time to chase this down, and while it's now apparently
> chased down, I'll certainly also be open to delaying until tomorrow if
> somebody has a patch to fix it.
> 
> So right now my plan is:
>  - I will revert those two later today and then release -rc1 in the evening
> UNLESS
>  - somebody posts a patch for the problem in the next few hours and
> Chris/others are willing to give it a good test overnight (or whatever
> people feel is "sufficient" based on how easily they can trigger the
> issue), in which case I'd do -rc1 tomorrow (either with the reverts or
> the patch, depending on how testing works out)

If a patch does come in, I'm happy to test it.  Mel had a test that
triggered within 1-2 minutes, mine took 30 or so, which means I'd want a
2 hour run to convince myself it was really fixed.  But, I'll give Mel's
fs_mark + dd workload a try on the buggy kernel.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
