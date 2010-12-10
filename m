Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 16C216B0088
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 11:27:18 -0500 (EST)
Date: Fri, 10 Dec 2010 17:27:06 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-ID: <20101210162706.GQ2356@cmpxchg.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
 <20101208141909.5c9c60e8.akpm@linux-foundation.org>
 <20101209000440.GM2356@cmpxchg.org>
 <20101209131723.fd51b032.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101209131723.fd51b032.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2010 at 01:17:23PM -0800, Andrew Morton wrote:
> Does that mean we can expect a v2?

Ok, while comparing Mel's patches with this change on IRC, I realized
that the enterprise kernel the issue was reported against is lacking
'de3fab3 vmscan: kswapd: don't retry balance_pgdat() if all zones are
unreclaimable'.

The above change fixed the observed malfunction of course, but Occam's
Razor suggests that de3fab3 will do so, too.  I'll verify that, but I
don't expect to send another version of this patch.

Sorry for the noise.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
