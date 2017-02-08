Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8676B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 07:44:45 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id w107so145150781ota.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 04:44:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o84si3158002oib.10.2017.02.08.04.44.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 04:44:44 -0800 (PST)
Subject: Re: [RFC PATCH] mm: move pcp and lru-pcp drainging into vmstat_wq
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170207210908.530-1-mhocko@kernel.org>
	<20170208105334.zbjuaaqwmp5rgpui@suse.de>
	<20170208120354.GI5686@dhcp22.suse.cz>
	<20170208123113.nq5unzmzpb23zoz5@suse.de>
In-Reply-To: <20170208123113.nq5unzmzpb23zoz5@suse.de>
Message-Id: <201702082144.BCE17682.SMOFOHJOVQLtFF@I-love.SAKURA.ne.jp>
Date: Wed, 8 Feb 2017 21:44:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de, mhocko@kernel.org
Cc: linux-mm@kvack.org, vbabka@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Mel Gorman wrote:
> > > It also feels like vmstat is now a misleading name for something that
> > > handles vmstat, lru drains and per-cpu drains but that's cosmetic.
> > 
> > yeah a better name sounds like a good thing. mm_nonblock_wq?
> > 
> 
> it's not always non-blocking. Maybe mm_percpu_wq to describev a workqueue
> that handles a variety of MM-related per-cpu updates?
> 

Why not make it global like ones created by workqueue_init_early() ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
