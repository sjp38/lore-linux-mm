Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ABC176B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 04:25:30 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v186so6017986wma.9
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 01:25:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i10si6176037edk.445.2017.11.20.01.25.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 01:25:29 -0800 (PST)
Date: Mon, 20 Nov 2017 10:25:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171120092526.llj2q3lqbbxwn4g4@dhcp22.suse.cz>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171117173521.GA21692@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171117173521.GA21692@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 17-11-17 09:35:21, Christoph Hellwig wrote:
> On Tue, Nov 14, 2017 at 06:37:42AM +0900, Tetsuo Handa wrote:
> > Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> > using one RCU section. But using atomic_inc()/atomic_dec() for each
> > do_shrink_slab() call will not impact so much.
> 
> But you could use SRCU..

Davidlohr has tried that already http://lkml.kernel.org/r/1434398602.1903.15.camel@stgolabs.net
and failed. Doing SRCU inside core kernel is not seen with a great
support...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
