Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 452396B2C68
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 18:45:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b29-v6so1235499pfm.1
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 15:45:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4-v6sor1815069pla.39.2018.08.23.15.45.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 15:45:47 -0700 (PDT)
Date: Thu, 23 Aug 2018 15:45:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
In-Reply-To: <cb2d635c-c14d-c2cc-868a-d4c447364f0d@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1808231544001.150774@chino.kir.corp.google.com>
References: <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp> <20180730144647.GX24267@dhcp22.suse.cz> <20180730145425.GE1206094@devbig004.ftw2.facebook.com> <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp> <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz> <20180730191005.GC24267@dhcp22.suse.cz> <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp> <20180731050928.GA4557@dhcp22.suse.cz> <d11c3aa2-0f14-d882-59c5-6634dc56eed1@i-love.sakura.ne.jp>
 <20180803061653.GB27245@dhcp22.suse.cz> <804b50cb-0b17-201a-790b-18604396f826@i-love.sakura.ne.jp> <alpine.DEB.2.21.1808231304080.15798@chino.kir.corp.google.com> <cb2d635c-c14d-c2cc-868a-d4c447364f0d@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 24 Aug 2018, Tetsuo Handa wrote:

> > For those of us who are tracking CVE-2016-10723 which has peristently been 
> > labeled as "disputed" and with no clear indication of what patches address 
> > it, I am assuming that commit 9bfe5ded054b ("mm, oom: remove sleep from 
> > under oom_lock") and this patch are the intended mitigations?
> > 
> > A list of SHA1s for merged fixed and links to proposed patches to address 
> > this issue would be appreciated.
> > 
> 
> Commit 9bfe5ded054b ("mm, oom: remove sleep from under oom_lock") is a
> mitigation for CVE-2016-10723.
> 
> "[PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
> should_reclaim_retry()." is independent from CVE-2016-10723.
> 

Thanks, Tetsuo.  Should commit af5679fbc669 ("mm, oom: remove oom_lock 
from oom_reaper") also be added to the list for CVE-2016-10723?
