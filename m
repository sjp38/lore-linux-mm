Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 312686B02D5
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 09:13:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n2-v6so7273450edr.5
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 06:13:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l26-v6si4910257edj.379.2018.07.09.06.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 06:13:38 -0700 (PDT)
Date: Mon, 9 Jul 2018 15:13:35 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER should always sleep at
 should_reclaim_retry().
Message-ID: <20180709131335.GM22049@dhcp22.suse.cz>
References: <1531046158-4010-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180709075731.GB22049@dhcp22.suse.cz>
 <5a5ddca9-95fd-1035-b304-a9c6d50238b2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a5ddca9-95fd-1035-b304-a9c6d50238b2@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Vladimir Davydov <vdavydov@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 09-07-18 22:08:04, Tetsuo Handa wrote:
> On 2018/07/09 16:57, Michal Hocko wrote:
[...]
> > [Tetsuo: changelog]
> >> Signed-off-by: Michal Hocko <mhocko@suse.com>
> >> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> >> Cc: David Rientjes <rientjes@google.com>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Joonsoo Kim <js1304@gmail.com>
> >> Cc: Mel Gorman <mgorman@suse.de>
> >> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> >> Cc: Vlastimil Babka <vbabka@suse.cz>
> > 
> > Your s-o-b is still missing.
> 
> all code changes in this patch is from you. That is, my s-o-b is not missing.

You are supposed to add your s-o-b if you are reposting a patch as
non-author to record to sender path properly.

-- 
Michal Hocko
SUSE Labs
