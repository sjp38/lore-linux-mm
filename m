Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC3956B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 05:14:18 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so2845209wjd.2
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 02:14:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h63si6891774wme.168.2017.02.02.02.14.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Feb 2017 02:14:17 -0800 (PST)
Date: Thu, 2 Feb 2017 11:14:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170202101415.GE22806@dhcp22.suse.cz>
References: <20170125101957.GA17632@lst.de>
 <20170125104605.GI32377@dhcp22.suse.cz>
 <201701252009.IHG13512.OFOJFSVLtOQMFH@I-love.SAKURA.ne.jp>
 <20170125130014.GO32377@dhcp22.suse.cz>
 <20170127144906.GB4148@dhcp22.suse.cz>
 <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
 <20170130085546.GF8443@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170130085546.GF8443@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Mon 30-01-17 09:55:46, Michal Hocko wrote:
> On Sun 29-01-17 00:27:27, Tetsuo Handa wrote:
[...]
> > Regarding [1], it helped avoiding the too_many_isolated() issue. I can't
> > tell whether it has any negative effect, but I got on the first trial that
> > all allocating threads are blocked on wait_for_completion() from flush_work()
> > in drain_all_pages() introduced by "mm, page_alloc: drain per-cpu pages from
> > workqueue context". There was no warn_alloc() stall warning message afterwords.
> 
> That patch is buggy and there is a follow up [1] which is not sitting in the
> mmotm (and thus linux-next) yet. I didn't get to review it properly and
> I cannot say I would be too happy about using WQ from the page
> allocator. I believe even the follow up needs to have WQ_RECLAIM WQ.
> 
> [1] http://lkml.kernel.org/r/20170125083038.rzb5f43nptmk7aed@techsingularity.net

Did you get chance to test with this follow up patch? It would be
interesting to see whether OOM situation can still starve the waiter.
The current linux-next should contain this patch.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
