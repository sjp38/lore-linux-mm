Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 332AA6B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 08:17:40 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id c33so1010555itf.8
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 05:17:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z135si101677ioe.60.2017.12.05.05.17.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 05:17:38 -0800 (PST)
Subject: Re: [PATCH 1/3] mm,oom: Move last second allocation to inside the OOM killer.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171201151715.yiep5wkmxmp77nxn@dhcp22.suse.cz>
	<20171201155711.GA11057@cmpxchg.org>
	<20171201163830.on5mykdtet2wa5is@dhcp22.suse.cz>
	<20171205104601.GA1898@cmpxchg.org>
	<20171205130215.bxkgzbzo25sljmgd@dhcp22.suse.cz>
In-Reply-To: <20171205130215.bxkgzbzo25sljmgd@dhcp22.suse.cz>
Message-Id: <201712052217.DGB21370.FHOFMLOJOFtVQS@I-love.SAKURA.ne.jp>
Date: Tue, 5 Dec 2017 22:17:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com

Michal Hocko wrote:
> > I do understand the upsides you're advocating for - although you
> > haven't quantified them. They're just not worth the downsides.
> 
> OK, fair enough. Let's drop the patch then. There is no _strong_
> justification for it and what I've seen as "nice to have" is indeed
> really hard to quantify and not really worth merging without a full
> consensus.

Dropping "mm,oom: move last second allocation to inside the OOM killer"
means dropping "mm,oom: remove oom_lock serialization from the OOM reaper"
together, right? The latter patch helped mitigating
schedule_timeout_killable(1) lockup problem though...

Also, what is the alternative for "mm,oom: use ALLOC_OOM for OOM victim's
last second allocation" ? I proposed "mm, oom: task_will_free_mem(current)
should ignore MMF_OOM_SKIP for once." and rejected by you. I also proposed
"mm,oom: Set ->signal->oom_mm to all thread groups sharing the victim's mm."
and rejected by you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
