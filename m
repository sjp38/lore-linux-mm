Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85F4F6B000A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:15:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y8-v6so749321edr.12
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 04:15:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d61-v6si407684edd.124.2018.07.31.04.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 04:15:21 -0700 (PDT)
Date: Tue, 31 Jul 2018 13:15:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180731111519.GH4557@dhcp22.suse.cz>
References: <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
 <20180730191005.GC24267@dhcp22.suse.cz>
 <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp>
 <20180731050928.GA4557@dhcp22.suse.cz>
 <b03f09c2-f749-9c80-b4f6-d0b4a9634013@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b03f09c2-f749-9c80-b4f6-d0b4a9634013@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 31-07-18 19:47:45, Tetsuo Handa wrote:
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
> 
> I'm saying that "we used to have a sleeping point in the oom path but this has been
> removed recently" is not true. You need to send that patch to linux.git first if you
> want to refer that patch in this patch.

That patch is already sitting in mmotm tree and this one will go on top.
I do not really see any reason to rush it to Linus tree. A dubious CVE
doesn't really raise the priority if you ask me.

On the other hand, having a confirmation, either of the above tags would
help to raise the credibility of the change.

> > I will send the patch to Andrew if the patch is ok. 
> 
> Andrew, can we send the "we used to have a sleeping point in the oom path but this has
> been removed recently" patch to linux.git ?

This can really wait for the next merge window IMHO.
-- 
Michal Hocko
SUSE Labs
