Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C18198D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 19:42:45 -0500 (EST)
Date: Tue, 1 Mar 2011 16:41:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove compaction from kswapd
Message-Id: <20110301164143.e44e5699.akpm@linux-foundation.org>
In-Reply-To: <AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com>
References: <20110228222138.GP22700@random.random>
	<AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com>
	<20110301223954.GI19057@random.random>
	<AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Wed, 2 Mar 2011 08:10:35 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Mar 2, 2011 at 7:39 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > On Wed, Mar 02, 2011 at 07:33:13AM +0900, Minchan Kim wrote:
> >> Sorry for bothering you but I think you get the data.
> >> It helps someone in future very much to know why we determined to
> >> remove the feature at that time and they should do what kinds of
> >> experiment to prove it has a benefit to add compaction in kswapd
> >> again.
> >
> > This is a benchmark I'm unsure if it's ok to publish results but it
> > should be possible to simulate it with a device driver.
> >
> > Arthur provided kswapd load usage data too, so I hope that's enough.
> >
> > My other patch (compaction-kswapd-3) is way better than current logic
> > and retains compaction in kswapd. That shows slightly higher
> > kswapd utilization with Arthur's multimedia workload, and a bit worse
> > performance on the network benchmark. So I thought it was better to go
> > with the fastest potion as long as we don't have a logic that uses
> > compaction and shows improved performance and lower latency than with
> > no compaction at all in kswapd.
> >
> 
> I didn't notice Arthur's problem.
> The patch seems to fix a real problem so I think it's enough.
> I wished you wrote down the link url about Arthur on LKML.
> 
> You can remove compact_mode of compact_control.
> Otherwise, looks good to me.
> 

I'd be pretty worried about jamming this into 2.6.38 at this late
stage.  And some vague talk about something Arthur did really doesn't
help a lot!  It would be better to have some good, solid quantitative
justification for what is really an emergency patch.  

Bear in mind that we always have a middle option: merge a patch into
2.6.39-rc1 and tag it for backporting into 2.6.38.x.  That gives us
more time to test it and to generally give it a shakedown.  But to make
decisions like that and to commend a patch to the -stable maintainers,
we need to provide better information please.

Also, "This goes on top of the two lowlatency fixes for compaction"
isn't particularly helpful.  I need to verify that the referred-to
patches are already in mainline but I don't have a clue what this
description refers to.  More specificity, please - it helps avoid
mistakes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
