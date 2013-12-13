Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6BA6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 21:00:23 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so1551990pdj.2
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 18:00:23 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id gn4si275022pbc.46.2013.12.12.18.00.20
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 18:00:22 -0800 (PST)
Date: Fri, 13 Dec 2013 11:03:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH V2 0/6] Memory compaction efficiency improvements
Message-ID: <20131213020323.GB8845@lge.com>
References: <1386757477-10333-1-git-send-email-vbabka@suse.cz>
 <20131212061223.GA5912@lge.com>
 <52A9B9A2.2050306@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A9B9A2.2050306@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

> >>stress-highalloc
> >>                              3.13-rc2              3.13-rc2              3.13-rc2              3.13-rc2              3.13-rc2
> >>                                 2-thp                 3-thp                 4-thp                 5-thp                 6-thp
> >>Success 1 Min          2.00 (  0.00%)        7.00 (-250.00%)       18.00 (-800.00%)       19.00 (-850.00%)       26.00 (-1200.00%)
> >>Success 1 Mean        19.20 (  0.00%)       17.80 (  7.29%)       29.20 (-52.08%)       29.90 (-55.73%)       32.80 (-70.83%)
> >>Success 1 Max         27.00 (  0.00%)       29.00 ( -7.41%)       35.00 (-29.63%)       36.00 (-33.33%)       37.00 (-37.04%)
> >>Success 2 Min          3.00 (  0.00%)        8.00 (-166.67%)       21.00 (-600.00%)       21.00 (-600.00%)       32.00 (-966.67%)
> >>Success 2 Mean        19.30 (  0.00%)       17.90 (  7.25%)       32.20 (-66.84%)       32.60 (-68.91%)       35.70 (-84.97%)
> >>Success 2 Max         27.00 (  0.00%)       30.00 (-11.11%)       36.00 (-33.33%)       37.00 (-37.04%)       39.00 (-44.44%)
> >>Success 3 Min         62.00 (  0.00%)       62.00 (  0.00%)       85.00 (-37.10%)       75.00 (-20.97%)       64.00 ( -3.23%)
> >>Success 3 Mean        66.30 (  0.00%)       65.50 (  1.21%)       85.60 (-29.11%)       83.40 (-25.79%)       83.50 (-25.94%)
> >>Success 3 Max         70.00 (  0.00%)       69.00 (  1.43%)       87.00 (-24.29%)       86.00 (-22.86%)       87.00 (-24.29%)
> >>
> >>             3.13-rc2    3.13-rc2    3.13-rc2    3.13-rc2    3.13-rc2
> >>                2-thp       3-thp       4-thp       5-thp       6-thp
> >>User         6547.93     6475.85     6265.54     6289.46     6189.96
> >>System       1053.42     1047.28     1043.23     1042.73     1038.73
> >>Elapsed      1835.43     1821.96     1908.67     1912.74     1956.38
> >
> >Hello, Vlastimil.
> >
> >I have some questions related to your stat, not your patchset,
> >just for curiosity. :)
> >
> >Are these results, "elapsed time" and "vmstat", for Success 3 line scenario?
> 
> No that's for the whole test which does the scenarios in succession.
> 

Okay!

> >If so, could you show me others?
> >I wonder why thp case consumes more system time rather than no-thp case.
> 
> Unfortunately these stats are not that useful as they don't
> distinguish the 3 phases and also include what the background load
> does. They are included just to show that nothing truly dramatic is
> happening.
> So
> 
> >And I found that elapsed time has no big difference between both cases,
> >roughly less than 2%. In this situation, do we get more benefits with
> >aggressive allocation like no-thp case?
> 
> Elapsed time suffers from the same problem, so it's again hard to
> say how relevant it actually is to the allocator workload and how
> much to background load. It seems that the more successful allocator
> is, the longer elapsed time (in both thp and nothp case). My guess
> is that less memory available for the background load makes it
> progress slower which affects the duration of the test as a whole.
> 
> I hope that in case of further compaction patches that would be
> potentially more intrusive to the its design (and not bugfixes and
> simple tweaks to the existing design as this series) I will have a
> more detailed breakdown of what time is spent where.

Okay!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
