Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E64EF6B0069
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 04:33:26 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 199so3039949pgg.20
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 01:33:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x6si267506pgp.181.2017.11.20.01.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 01:33:25 -0800 (PST)
Date: Mon, 20 Nov 2017 01:33:09 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171120093309.GA19627@infradead.org>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171117173521.GA21692@infradead.org>
 <20171120092526.llj2q3lqbbxwn4g4@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171120092526.llj2q3lqbbxwn4g4@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 20, 2017 at 10:25:26AM +0100, Michal Hocko wrote:
> On Fri 17-11-17 09:35:21, Christoph Hellwig wrote:
> > On Tue, Nov 14, 2017 at 06:37:42AM +0900, Tetsuo Handa wrote:
> > > Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> > > using one RCU section. But using atomic_inc()/atomic_dec() for each
> > > do_shrink_slab() call will not impact so much.
> > 
> > But you could use SRCU..
> 
> Davidlohr has tried that already http://lkml.kernel.org/r/1434398602.1903.15.camel@stgolabs.net
> and failed. Doing SRCU inside core kernel is not seen with a great
> support...

I can't actually find any objection in that thread.  What's the problem
Davidlohr ran into?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
