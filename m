Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2D96B000D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 02:16:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t10-v6so1468051eds.7
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 23:16:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d61-v6si3137604edd.124.2018.08.02.23.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 23:16:55 -0700 (PDT)
Date: Fri, 3 Aug 2018 08:16:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180803061653.GB27245@dhcp22.suse.cz>
References: <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
 <20180730191005.GC24267@dhcp22.suse.cz>
 <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp>
 <20180731050928.GA4557@dhcp22.suse.cz>
 <d11c3aa2-0f14-d882-59c5-6634dc56eed1@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d11c3aa2-0f14-d882-59c5-6634dc56eed1@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 03-08-18 07:05:54, Tetsuo Handa wrote:
> On 2018/07/31 14:09, Michal Hocko wrote:
> > On Tue 31-07-18 06:01:48, Tetsuo Handa wrote:
> >> On 2018/07/31 4:10, Michal Hocko wrote:
> >>> Since should_reclaim_retry() should be a natural reschedule point,
> >>> let's do the short sleep for PF_WQ_WORKER threads unconditionally in
> >>> order to guarantee that other pending work items are started. This will
> >>> workaround this problem and it is less fragile than hunting down when
> >>> the sleep is missed. E.g. we used to have a sleeping point in the oom
> >>> path but this has been removed recently because it caused other issues.
> >>> Having a single sleeping point is more robust.
> >>
> >> linux.git has not removed the sleeping point in the OOM path yet. Since removing the
> >> sleeping point in the OOM path can mitigate CVE-2016-10723, please do so immediately.
> > 
> > is this an {Acked,Reviewed,Tested}-by?
> > 
> > I will send the patch to Andrew if the patch is ok. 
> > 
> >> (And that change will conflict with Roman's cgroup aware OOM killer patchset. But it
> >> should be easy to rebase.)
> > 
> > That is still a WIP so I would lose sleep over it.
> > 
> 
> Now that Roman's cgroup aware OOM killer patchset will be dropped from linux-next.git ,
> linux-next.git will get the sleeping point removed. Please send this patch to linux-next.git .

I still haven't heard any explicit confirmation that the patch works for
your workload. Should I beg for it? Or you simply do not want to have
your stamp on the patch? If yes, I can live with that but this playing
hide and catch is not really a lot of fun.

-- 
Michal Hocko
SUSE Labs
