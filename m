Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 142FF8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 00:58:39 -0500 (EST)
Date: Tue, 1 Mar 2011 21:57:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove compaction from kswapd
Message-Id: <20110301215759.f723c9bc.akpm@linux-foundation.org>
In-Reply-To: <20110302055221.GD23911@random.random>
References: <20110228222138.GP22700@random.random>
	<AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com>
	<20110301223954.GI19057@random.random>
	<AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com>
	<20110301164143.e44e5699.akpm@linux-foundation.org>
	<20110302043856.GB23911@random.random>
	<20110301205324.f0daaf86.akpm@linux-foundation.org>
	<20110302055221.GD23911@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Wed, 2 Mar 2011 06:52:21 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> These are the other two patches that are needed for both workloads to
> be better than before.
> 
> mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-pages-for-migration
> mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-free-pages

I have those queued for 2.6.39 - they didn't seem terribly critical and
no mention of NMI watchdog timeouts was made.

Guys, this stuff matters :(  Should both go into 2.6.38?  If so, why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
