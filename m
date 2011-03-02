Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7C88D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 23:53:54 -0500 (EST)
Date: Tue, 1 Mar 2011 20:53:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove compaction from kswapd
Message-Id: <20110301205324.f0daaf86.akpm@linux-foundation.org>
In-Reply-To: <20110302043856.GB23911@random.random>
References: <20110228222138.GP22700@random.random>
	<AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com>
	<20110301223954.GI19057@random.random>
	<AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com>
	<20110301164143.e44e5699.akpm@linux-foundation.org>
	<20110302043856.GB23911@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Wed, 2 Mar 2011 05:38:56 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Tue, Mar 01, 2011 at 04:41:43PM -0800, Andrew Morton wrote:
> > I'd be pretty worried about jamming this into 2.6.38 at this late
> > stage.  And some vague talk about something Arthur did really doesn't
> > help a lot!  It would be better to have some good, solid quantitative
> > justification for what is really an emergency patch.  
> 
> It is a emergency patch. This is zero risk, this brings back kswapd in
> 2.6.37 status!

The original patch description didn't explain this.

And no patch is "zero risk", especially at -rc6.

> 2.6.38 added a new feature, I'm reverting it because
> it's screwing benchmarks.

And we have no useful information about benchmark results.

> > Bear in mind that we always have a middle option: merge a patch into
> > 2.6.39-rc1 and tag it for backporting into 2.6.38.x.  That gives us
> > more time to test it and to generally give it a shakedown.  But to make
> > decisions like that and to commend a patch to the -stable maintainers,
> > we need to provide better information please.
> 
> This is 100% tested in 2.6.37. The new code was tested in 2.6.38-rc
> and testing return -EFAIL. So we must revert this change.

What change?  Commit ID?  What testing returned -EFAIL?  That's
different from slower benchmark results.

> This patch
> is doing nothing but reverting compaction-kswapd code merged in
> 2.6.38-rc. The old code is fully tested.
> 
> > Also, "This goes on top of the two lowlatency fixes for compaction"
> > isn't particularly helpful.  I need to verify that the referred-to
> > patches are already in mainline but I don't have a clue what this
> > description refers to.  More specificity, please - it helps avoid
> > mistakes.
> 
> Those two patches are fully orthogonal with this one.

*What* two patches???  I don't have a clue which patches you're referring to. 
Patches have names, please use them.

> Andrew already
> has them in -mm and there's no need to analyse those simultaneously
> with this one.
> 
> I mentioned those two because those two are also important fixes to
> avoid compaction to disable interrupts for too long, but they have no
> actual relation to this one. One of the two fixes that Mel sent was
> actually embedded into my patch but he splitted it off rightfully
> because it has no relation.

This is just hopeless.  Please, just send the thing again and this time
include a *full* description of what it does and why it does it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
