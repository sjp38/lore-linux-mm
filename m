Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D39688D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 12:22:07 -0500 (EST)
Date: Wed, 2 Mar 2011 18:21:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] remove compaction from kswapd
Message-ID: <20110302172141.GF23911@random.random>
References: <20110228222138.GP22700@random.random>
 <AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com>
 <20110301223954.GI19057@random.random>
 <AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com>
 <20110301164143.e44e5699.akpm@linux-foundation.org>
 <20110302043856.GB23911@random.random>
 <20110301205324.f0daaf86.akpm@linux-foundation.org>
 <20110302055221.GD23911@random.random>
 <20110301215759.f723c9bc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110301215759.f723c9bc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Tue, Mar 01, 2011 at 09:57:59PM -0800, Andrew Morton wrote:
> On Wed, 2 Mar 2011 06:52:21 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > These are the other two patches that are needed for both workloads to
> > be better than before.
> > 
> > mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-pages-for-migration
> > mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-free-pages
> 
> I have those queued for 2.6.39 - they didn't seem terribly critical and
> no mention of NMI watchdog timeouts was made.
> 
> Guys, this stuff matters :(  Should both go into 2.6.38?  If so, why?

Ok: before commit 5a03b051ed87e72b959f32a86054e1142ac4cf55 it was
unnoticeable problem (the above two patches are fixing longstanding
bugs). But the combination of kswapd running compaction in a loop
after commit 5a03b051ed87e72b959f32a86054e1142ac4cf55, and compaction
keeping irqs disabled for too long (longstanding bug, but unnoticed
before 5a03b051ed87e72b959f32a86054e1142ac4cf55), shows both
problems. If you have a single problem you don't notice so much the
other one. But kswapd calling compaction in a loop, and compaction
keeping irqs disabled for too long are separate problems that shows
each other.

I think we want the above two patches and the patch Mel sent with
Message-ID: <20110302142542.GE14162@csn.ul.ie> in 2.6.38.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
