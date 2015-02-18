Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 226856B0089
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 09:06:27 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so1506171pab.0
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 06:06:26 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f5si18423480pat.226.2015.02.18.06.06.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 06:06:25 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150217165024.GI32017@dhcp22.suse.cz>
	<20150217232552.GK4251@dastard>
	<20150218084842.GB4478@dhcp22.suse.cz>
	<201502182023.EEJ12920.QFFMOVtOSJLHFO@I-love.SAKURA.ne.jp>
	<20150218122903.GD4478@dhcp22.suse.cz>
In-Reply-To: <20150218122903.GD4478@dhcp22.suse.cz>
Message-Id: <201502182306.HAB60908.MVQFOHJSOOFLFt@I-love.SAKURA.ne.jp>
Date: Wed, 18 Feb 2015 23:06:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

Michal Hocko wrote:
> Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > Because they cannot perform any IO/FS transactions and that would lead
> > > to a premature OOM conditions way too easily. OOM killer is a _last
> > > resort_ reclaim opportunity not something that would happen just because
> > > you happen to be not able to flush dirty pages. 
> > 
> > But you should not have applied such change without making necessary
> > changes to GFP_NOFS / GFP_NOIO users with such expectation and testing
> > at linux-next.git . Applying such change after 3.19-rc6 is a sucker punch.
> 
> This is a nonsense. OOM was disbaled for !__GFP_FS for ages (since
> before git era).
>  
Then, at least I expect that filesystem error actions will not be taken so
trivially. Can we apply http://marc.info/?l=linux-mm&m=142418465615672&w=2 for
Linux 3.19-stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
