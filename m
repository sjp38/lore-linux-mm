Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBC856B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:55:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o60-v6so3412199edd.13
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 04:55:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p62-v6si4223899edb.161.2018.07.31.04.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 04:55:06 -0700 (PDT)
Date: Tue, 31 Jul 2018 13:55:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180731115504.GJ4557@dhcp22.suse.cz>
References: <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
 <20180730191005.GC24267@dhcp22.suse.cz>
 <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp>
 <20180731050928.GA4557@dhcp22.suse.cz>
 <b03f09c2-f749-9c80-b4f6-d0b4a9634013@i-love.sakura.ne.jp>
 <20180731111519.GH4557@dhcp22.suse.cz>
 <08292e78-9a28-12ec-4164-2934cde5be51@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <08292e78-9a28-12ec-4164-2934cde5be51@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 31-07-18 20:30:08, Tetsuo Handa wrote:
> On 2018/07/31 20:15, Michal Hocko wrote:
> >>> I will send the patch to Andrew if the patch is ok. 
> >>
> >> Andrew, can we send the "we used to have a sleeping point in the oom path but this has
> >> been removed recently" patch to linux.git ?
> > 
> > This can really wait for the next merge window IMHO.
> > 
> 
> "mm, oom: cgroup-aware OOM killer" in linux-next.git is reviving that sleeping point.
> Current "mm, oom: cgroup-aware OOM killer" will not be sent to linux.git in the next
> merge window? I'm confused...

This has nothing to do with cgroup-aware OOM killer.

-- 
Michal Hocko
SUSE Labs
