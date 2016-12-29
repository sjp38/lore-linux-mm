Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2836B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 02:56:54 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 2so63676921uax.4
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 23:56:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h125si27338551wme.3.2016.12.28.23.56.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 23:56:52 -0800 (PST)
Date: Thu, 29 Dec 2016 08:56:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20161229075649.GB29208@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-5-mhocko@kernel.org>
 <20161229060204.GC1815@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161229060204.GC1815@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 29-12-16 15:02:04, Minchan Kim wrote:
> On Wed, Dec 28, 2016 at 04:30:29PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> > from is file or anonymous but we do not know which LRU this is. It is
> > useful to know whether the list is file or anonymous as well. Change
> > the tracepoint to show symbolic names of the lru rather.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Not exactly same with this but idea is almost same.
> I used almost same tracepoint to investigate agging(i.e., deactivating) problem
> in 32b kernel with node-lru.
> It was enough. Namely, I didn't need tracepoint in shrink_active_list like your
> first patch.
> Your first patch is more straightforwad and information. But as you introduced
> this patch, I want to ask in here.
> Isn't it enough with this patch without your first one to find a such problem?

I assume this should be a reply to
http://lkml.kernel.org/r/20161228153032.10821-8-mhocko@kernel.org, right?
And you are right that for the particular problem it was enough to have
a tracepoint inside inactive_list_is_low and shrink_active_list one
wasn't really needed. On the other hand aging issues are really hard to
debug as well and so I think that both are useful. The first one tell us
_why_ we do aging while the later _how_ we do that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
