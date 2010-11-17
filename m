Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C5A238D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:48:03 -0500 (EST)
Date: Wed, 17 Nov 2010 15:46:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/8] Use memory compaction instead of lumpy reclaim
 during high-order allocations
Message-Id: <20101117154641.51fd7ce5.akpm@linux-foundation.org>
In-Reply-To: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010 16:22:41 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> Huge page allocations are not expected to be cheap but lumpy reclaim
> is still very disruptive.

Huge pages are boring.  Can we expect any benefit for the
stupid-nic-driver-which-does-order-4-GFP_ATOMIC-allocations problem?

>
> ...
>
> I haven't pushed hard on the concept of lumpy compaction yet and right
> now I don't intend to during this cycle. The initial prototypes did not
> behave as well as expected and this series improves the current situation
> a lot without introducing new algorithms. Hence, I'd like this series to
> be considered for merging.

Translation: "Andrew, wait for the next version"? :)

> I'm hoping that this series also removes the
> necessity for the "delete lumpy reclaim" patch from the THP tree.

Now I'm sad.  I read all that and was thinking "oh goody, we get to
delete something for once".  But no :(

If you can get this stuff to work nicely, why can't we remove lumpy
reclaim?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
