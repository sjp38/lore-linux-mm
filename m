Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA056B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 04:42:40 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c82so1387054wme.8
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 01:42:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si7500874edh.158.2017.11.20.01.42.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 01:42:39 -0800 (PST)
Date: Mon, 20 Nov 2017 10:42:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171120094237.z6h3kx3ne5ld64pl@dhcp22.suse.cz>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171117173521.GA21692@infradead.org>
 <20171120092526.llj2q3lqbbxwn4g4@dhcp22.suse.cz>
 <20171120093309.GA19627@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171120093309.GA19627@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 20-11-17 01:33:09, Christoph Hellwig wrote:
> On Mon, Nov 20, 2017 at 10:25:26AM +0100, Michal Hocko wrote:
> > On Fri 17-11-17 09:35:21, Christoph Hellwig wrote:
> > > On Tue, Nov 14, 2017 at 06:37:42AM +0900, Tetsuo Handa wrote:
> > > > Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> > > > using one RCU section. But using atomic_inc()/atomic_dec() for each
> > > > do_shrink_slab() call will not impact so much.
> > > 
> > > But you could use SRCU..
> > 
> > Davidlohr has tried that already http://lkml.kernel.org/r/1434398602.1903.15.camel@stgolabs.net
> > and failed. Doing SRCU inside core kernel is not seen with a great
> > support...
> 
> I can't actually find any objection in that thread.  What's the problem
> Davidlohr ran into?

The patch has been dropped because allnoconfig failed to compile back
then http://lkml.kernel.org/r/CAP=VYLr0rPWi1aeuk4w1On9CYRNmnEWwJgGtaX=wEvGaBURtrg@mail.gmail.com
I have problem to find the follow up discussion though. The main
argument was that SRC is not generally available and so the core
kernel should rely on it.
-- 
Michal Hocko SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
