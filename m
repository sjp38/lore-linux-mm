Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD5036B7383
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 10:04:56 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a10-v6so3784272pls.23
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 07:04:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9-v6si2348420pll.298.2018.09.05.07.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 07:04:55 -0700 (PDT)
Date: Wed, 5 Sep 2018 16:04:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180905140451.GG14951@dhcp22.suse.cz>
References: <cb2d635c-c14d-c2cc-868a-d4c447364f0d@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1808231544001.150774@chino.kir.corp.google.com>
 <201808240031.w7O0V5hT019529@www262.sakura.ne.jp>
 <195a512f-aecc-f8cf-f409-6c42ee924a8c@i-love.sakura.ne.jp>
 <20180905134038.GE14951@dhcp22.suse.cz>
 <81cc1f29-e42e-7813-dc70-5d6d9e999dd1@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <81cc1f29-e42e-7813-dc70-5d6d9e999dd1@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 05-09-18 22:53:33, Tetsuo Handa wrote:
> On 2018/09/05 22:40, Michal Hocko wrote:
> > Changelog said 
> > 
> > "Although this is possible in principle let's wait for it to actually
> > happen in real life before we make the locking more complex again."
> > 
> > So what is the real life workload that hits it? The log you have pasted
> > below doesn't tell much.
> 
> Nothing special. I just ran a multi-threaded memory eater on a CONFIG_PREEMPT=y kernel.

I strongly suspec that your test doesn't really represent or simulate
any real and useful workload. Sure it triggers a rare race and we kill
another oom victim. Does this warrant to make the code more complex?
Well, I am not convinced, as I've said countless times.
-- 
Michal Hocko
SUSE Labs
