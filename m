Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16B846B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 05:52:39 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so97169189lfc.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:52:39 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t83si19148034wmf.28.2016.05.16.02.52.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 02:52:37 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so16758176wmw.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:52:37 -0700 (PDT)
Date: Mon, 16 May 2016 11:52:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 12/13] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160516095236.GF23146@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-13-git-send-email-vbabka@suse.cz>
 <20160513141539.GR20141@dhcp22.suse.cz>
 <57397760.4060407@suse.cz>
 <20160516081439.GD23146@dhcp22.suse.cz>
 <5739929C.5000500@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5739929C.5000500@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon 16-05-16 11:27:56, Vlastimil Babka wrote:
> On 05/16/2016 10:14 AM, Michal Hocko wrote:
> > On Mon 16-05-16 09:31:44, Vlastimil Babka wrote:
[...]
> > > Also my understanding of the initial compaction priorities is to lower the
> > > latency if fragmentation is just light and there's enough memory. Once we
> > > start struggling, I don't see much point in not switching to the full
> > > compaction priority quickly.
> > 
> > That is true but why to compact when there are high order pages and they
> > are just hidden by the watermark check.
> 
> Compaction should skip such zone regardless of priority.

The point I've tried to raise is that we shouldn't conflate the purpose
of the two. The reclaim is here primarily to get us over the watermarks
while compaction is here to form high order pages. If we get both
together the distinction is blured which, I believe, will lead to more
complicated code in the end. I might be wrong here of course but let's
try to have compaction as much wmark check free as possible.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
