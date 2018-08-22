Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE4E6B232B
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 03:32:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d47-v6so560030edb.3
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 00:32:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15-v6si831339eds.222.2018.08.22.00.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 00:32:05 -0700 (PDT)
Date: Wed, 22 Aug 2018 09:32:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180822073204.GC29735@dhcp22.suse.cz>
References: <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
 <20180730191005.GC24267@dhcp22.suse.cz>
 <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp>
 <20180731050928.GA4557@dhcp22.suse.cz>
 <d11c3aa2-0f14-d882-59c5-6634dc56eed1@i-love.sakura.ne.jp>
 <20180803061653.GB27245@dhcp22.suse.cz>
 <804b50cb-0b17-201a-790b-18604396f826@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <804b50cb-0b17-201a-790b-18604396f826@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 22-08-18 06:07:40, Tetsuo Handa wrote:
> On 2018/08/03 15:16, Michal Hocko wrote:
[...]
> >> Now that Roman's cgroup aware OOM killer patchset will be dropped from linux-next.git ,
> >> linux-next.git will get the sleeping point removed. Please send this patch to linux-next.git .
> > 
> > I still haven't heard any explicit confirmation that the patch works for
> > your workload. Should I beg for it? Or you simply do not want to have
> > your stamp on the patch? If yes, I can live with that but this playing
> > hide and catch is not really a lot of fun.
> > 
> 
> I noticed that the patch has not been sent to linux-next.git yet.
> Please send to linux-next.git without my stamp on the patch.

I plan to do so after merge window closes.
-- 
Michal Hocko
SUSE Labs
