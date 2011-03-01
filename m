Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D447B8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 17:33:15 -0500 (EST)
Received: by iyf13 with SMTP id 13so5840575iyf.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 14:33:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110228222138.GP22700@random.random>
References: <20110228222138.GP22700@random.random>
Date: Wed, 2 Mar 2011 07:33:13 +0900
Message-ID: <AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com>
Subject: Re: [PATCH] remove compaction from kswapd
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Tue, Mar 1, 2011 at 7:21 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> This is important to apply in 2.6.38. The imporoved
> compaction-in-kswapd logic worked much better then the upstream one,
> but performance was still a little better with no compaction in
> kswapd. This is also somewhat saver as it removes a feature (that is
> hurting performance a bit) instead of improving it. We used a network
> benchmark. This is also confirmed by Arthur on lkml using a different
> multimedia workload and checking kswapd CPU utilization.

Could you provide the result of benchmark and input from others in description?

Sorry for bothering you but I think you get the data.
It helps someone in future very much to know why we determined to
remove the feature at that time and they should do what kinds of
experiment to prove it has a benefit to add compaction in kswapd
again.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
