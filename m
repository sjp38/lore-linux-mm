Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C65056B000A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:46:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id s1-v6so3204784pfm.22
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:46:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f18-v6si10506289pgi.300.2018.07.30.07.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 07:46:50 -0700 (PDT)
Date: Mon, 30 Jul 2018 16:46:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180730144647.GX24267@dhcp22.suse.cz>
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
 <20180726113958.GE28386@dhcp22.suse.cz>
 <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
 <20180730093257.GG24267@dhcp22.suse.cz>
 <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 30-07-18 23:34:23, Tetsuo Handa wrote:
> On 2018/07/30 18:32, Michal Hocko wrote:
[...]
> > This one is waiting for draining and we are in mm_percpu_wq WQ context
> > which has its rescuer so no other activity can block us for ever. So
> > this certainly shouldn't deadlock. It can be dead slow but well, this is
> > what you will get when your shoot your system to death.
> 
> We need schedule_timeout_*() to allow such WQ_MEM_RECLAIM workqueues to wake up. (Tejun,
> is my understanding correct?) Lack of schedule_timeout_*() does block WQ_MEM_RECLAIM
> workqueues forever.

Hmm. This doesn't match my understanding of what WQ_MEM_RECLAIM actually
guarantees. If you are right then the whole thing sounds quite fragile
to me TBH.

Anyway we would at least have an explanation for what you are seeing.
-- 
Michal Hocko
SUSE Labs
