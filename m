Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAEFC6B02B4
	for <linux-mm@kvack.org>; Tue, 30 May 2017 09:45:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k57so6764933wrk.6
        for <linux-mm@kvack.org>; Tue, 30 May 2017 06:45:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k19si11259544ede.23.2017.05.30.06.45.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 May 2017 06:45:55 -0700 (PDT)
Date: Tue, 30 May 2017 15:45:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: add tracepoints for oom reaper-related events
Message-ID: <20170530134552.GI7969@dhcp22.suse.cz>
References: <1496145932-18636-1-git-send-email-guro@fb.com>
 <20170530123415.GF7969@dhcp22.suse.cz>
 <20170530133335.GB28148@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530133335.GB28148@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 30-05-17 14:33:35, Roman Gushchin wrote:
> On Tue, May 30, 2017 at 02:34:16PM +0200, Michal Hocko wrote:
> > On Tue 30-05-17 13:05:32, Roman Gushchin wrote:
> > > Add tracepoints to simplify the debugging of the oom reaper code.
> > > 
> > > Trace the following events:
> > > 1) a process is marked as an oom victim,
> > > 2) a process is added to the oom reaper list,
> > > 3) the oom reaper starts reaping process's mm,
> > > 4) the oom reaper finished reaping,
> > > 5) the oom reaper skips reaping.
> > 
> > I am not against but could you explain why the current printks are not
> > sufficient? We do not have any explicit printk for the 2) and 3) but
> > are those really necessary?
> 
> We also don't have any printks for 1) and 2) if, for, instance, we call
> out_of_memory() and task_will_free_mem(current) returns true.
> 
> > 
> > In other words could you describe the situation when you found these
> > tracepoints more useful than what the kernel log offers already?
> 
> During my work on cgroup-aware OOM killer and some issues discovered
> in process (which are described in https://lkml.org/lkml/2017/5/17/542;
> most important problem fixed by Tetsuo), I've found an existing debug output
> insufficient and sometimes too bulky.
> 
> Suggested traces allowed me to debug issues like I've met (double invocation
> of oom_reaper, etc) much easier.

Please describe those and examples how the new tracepoints will be
useful in the changelog.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
