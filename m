Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 212028D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 17:18:23 -0500 (EST)
Date: Wed, 9 Mar 2011 14:17:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove compaction from kswapd
Message-Id: <20110309141718.93db5ea5.akpm@linux-foundation.org>
In-Reply-To: <20110302142542.GE14162@csn.ul.ie>
References: <20110228222138.GP22700@random.random>
	<AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com>
	<20110301223954.GI19057@random.random>
	<AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com>
	<20110301164143.e44e5699.akpm@linux-foundation.org>
	<20110302043856.GB23911@random.random>
	<20110301205324.f0daaf86.akpm@linux-foundation.org>
	<20110302055221.GD23911@random.random>
	<20110302142542.GE14162@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, stable@kernel.org

On Wed, 2 Mar 2011 14:25:42 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> mm: compaction: Prevent kswapd compacting memory to reduce CPU usage
> 
> This patch reverts [5a03b051: thp: use compaction in kswapd for GFP_ATOMIC
> order > 0] due to reports stating that kswapd CPU usage was higher
> and IRQs were being disabled more frequently. This was reported at
> http://www.spinics.net/linux/fedora/alsa-user/msg09885.html .

OK, I grabbed this.

I made a number of changelog changes:

- Rewrote it as From: Andrea (correct?)

- Replaced your acked-by with signed-off-by, as you were on the
  delivery path

- Hunted down Arthur's email address and added his reported-by and
  tested-by.

- Added cc:stable, as it's a bit late for 2.6.38.  The intention
  being that we put this into 2.6.38.1 after it has cooked in 2.6.39-rcX
  for a while.  OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
