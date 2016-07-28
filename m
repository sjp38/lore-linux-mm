Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6666B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 06:27:57 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so13595974lfw.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:27:57 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id h10si12256972wjl.4.2016.07.28.03.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 03:27:55 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 923231C1D31
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 11:27:53 +0100 (IST)
Date: Thu, 28 Jul 2016 11:27:51 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/5] Candidate fixes for premature OOM kills with
 node-lru v2
Message-ID: <20160728102751.GB2799@techsingularity.net>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <20160726081129.GB15721@js1304-P5Q-DELUXE>
 <20160726125050.GP10438@techsingularity.net>
 <20160728064432.GA28136@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160728064432.GA28136@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 28, 2016 at 03:44:33PM +0900, Joonsoo Kim wrote:
> > To some extent, it could be "addressed" by immediately reclaiming active
> > pages moving to the inactive list at the cost of distorting page age for a
> > workload that is genuinely close to OOM. That is similar to what zone-lru
> > ended up doing -- fast reclaiming young pages from a zone.
> 
> My expectation on my test case is that reclaimers should kick out
> actively used page and make a room for 'fork' because parallel readers
> would work even if reading pages are not cached.
> 
> It is sensitive on reclaimers efficiency because parallel readers
> read pages repeatedly and disturb reclaim. I thought that it is a
> good test for node-lru which changes reclaimers efficiency for lower
> zone. However, as you said, this efficiency comes from the cost
> distorting page aging so now I'm not sure if it is a problem that we
> need to consider. Let's skip it?
> 

I think we should skip it for now. The alterations are too specific to a
test case that is very close to being genuinely OOM. Adjusting timing
for one OOM case may just lead to complains that OOM is detected too
slowly in others.

> Anyway, thanks for tracking down the problem.
> 

My pleasure, thanks to both you and Minchan for persisting with this as
we got some important fixes out of the discussion.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
