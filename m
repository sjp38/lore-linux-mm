Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8E06B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 15:32:35 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a125so22561829wmd.0
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 12:32:35 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id lz8si1839342wjb.121.2016.04.19.12.32.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 12:32:34 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id l6so7858350wml.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 12:32:33 -0700 (PDT)
Date: Tue, 19 Apr 2016 15:32:31 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom_reaper: clear TIF_MEMDIE for all tasks
 queued for oom_reaper
Message-ID: <20160419193230.GA9270@dhcp22.suse.cz>
References: <20160408113425.GF29820@dhcp22.suse.cz>
 <201604161151.ECG35947.FFLtSFVQJOHOOM@I-love.SAKURA.ne.jp>
 <20160417115422.GA21757@dhcp22.suse.cz>
 <201604182059.JFB76917.OFJMHFLSOtQVFO@I-love.SAKURA.ne.jp>
 <20160419141722.GB4126@dhcp22.suse.cz>
 <201604200007.IFD52169.FLSOOVQHJOFFtM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604200007.IFD52169.FLSOOVQHJOFFtM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Wed 20-04-16 00:07:50, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 18-04-16 20:59:51, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > Here is what should work - I have only compile tested it. I will prepare
> > > > the proper patch later this week with other oom reaper patches or after
> > > > I come back from LSF/MM.
> > > 
> > > Excuse me, but is system_wq suitable for queuing operations which may take
> > > unpredictable duration to flush?
> > > 
> > >   system_wq is the one used by schedule[_delayed]_work[_on]().
> > >   Multi-CPU multi-threaded.  There are users which expect relatively
> > >   short queue flush time.  Don't queue works which can run for too
> > >   long.
> > 
> > An alternative would be using a dedicated WQ with WQ_MEM_RECLAIM which I
> > am not really sure would be justified considering we are talking about a
> > highly unlikely event. You do not want to consume resources permanently
> > for an eventual and not fatal event.
> 
> Yes, the reason SysRq-f is still not using a dedicated WQ with WQ_MEM_RECLAIM
> will be the same.

sysrq+f can use the oom_reaper kernel thread.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
