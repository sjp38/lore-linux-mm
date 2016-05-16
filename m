Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 80B6C6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 04:11:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s63so38953374wme.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 01:11:28 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id g128si18702568wmg.98.2016.05.16.01.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 01:11:27 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id g17so122927462wme.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 01:11:27 -0700 (PDT)
Date: Mon, 16 May 2016 10:11:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 11/13] mm, compaction: add the ultimate direct compaction
 priority
Message-ID: <20160516081125.GC23146@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-12-git-send-email-vbabka@suse.cz>
 <20160513133851.GP20141@dhcp22.suse.cz>
 <573973F7.7070202@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573973F7.7070202@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon 16-05-16 09:17:11, Vlastimil Babka wrote:
> On 05/13/2016 03:38 PM, Michal Hocko wrote:
> > On Tue 10-05-16 09:36:01, Vlastimil Babka wrote:
[...]
> > > such as hugetlbfs allocations, and reduce some corner-case OOM's for non-costly
> > > allocations.
> > 
> > My testing has shown that even with the current implementation with
> > deferring, skip hints and cached positions had (close to) 100% success
> > rate even with close to OOM conditions.
> 
> Hmm, I thought you at one point said that ignoring skip hints was a large
> improvement, because the current resetting of them is just too fuzzy.

Not in the hugetlb test. But you are right that skip hints resulted in
really fuzzy behavior.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
