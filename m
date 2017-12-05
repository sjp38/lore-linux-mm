Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 909066B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 08:42:23 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l33so144148wrl.5
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 05:42:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b37si314945eda.69.2017.12.05.05.42.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 05:42:21 -0800 (PST)
Date: Tue, 5 Dec 2017 14:42:20 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/3] mm,oom: Move last second allocation to inside the
 OOM killer.
Message-ID: <20171205134220.vwz5d23vtr3nocfs@dhcp22.suse.cz>
References: <20171201151715.yiep5wkmxmp77nxn@dhcp22.suse.cz>
 <20171201155711.GA11057@cmpxchg.org>
 <20171201163830.on5mykdtet2wa5is@dhcp22.suse.cz>
 <20171205104601.GA1898@cmpxchg.org>
 <20171205130215.bxkgzbzo25sljmgd@dhcp22.suse.cz>
 <201712052217.DGB21370.FHOFMLOJOFtVQS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712052217.DGB21370.FHOFMLOJOFtVQS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com

On Tue 05-12-17 22:17:27, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > I do understand the upsides you're advocating for - although you
> > > haven't quantified them. They're just not worth the downsides.
> > 
> > OK, fair enough. Let's drop the patch then. There is no _strong_
> > justification for it and what I've seen as "nice to have" is indeed
> > really hard to quantify and not really worth merging without a full
> > consensus.
> 
> Dropping "mm,oom: move last second allocation to inside the OOM killer"
> means dropping "mm,oom: remove oom_lock serialization from the OOM reaper"
> together, right?

No, I believe that we can drop the lock even without this patch. This
will need more investigation though.

> The latter patch helped mitigating
> schedule_timeout_killable(1) lockup problem though...
> 
> Also, what is the alternative for "mm,oom: use ALLOC_OOM for OOM victim's
> last second allocation" ? I proposed "mm, oom: task_will_free_mem(current)
> should ignore MMF_OOM_SKIP for once." and rejected by you. I also proposed
> "mm,oom: Set ->signal->oom_mm to all thread groups sharing the victim's mm."
> and rejected by you.

Yes, and so far I am not really sure we have to care all that much. I
haven't seen any real world workload actually hitting this condition.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
