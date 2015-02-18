Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 420A76B0093
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 09:26:01 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id l15so41309173wiw.5
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 06:26:00 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1si33923754wia.95.2015.02.18.06.25.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 06:25:59 -0800 (PST)
Date: Wed, 18 Feb 2015 15:25:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150218142557.GE4478@dhcp22.suse.cz>
References: <20150217165024.GI32017@dhcp22.suse.cz>
 <20150217232552.GK4251@dastard>
 <20150218084842.GB4478@dhcp22.suse.cz>
 <201502182023.EEJ12920.QFFMOVtOSJLHFO@I-love.SAKURA.ne.jp>
 <20150218122903.GD4478@dhcp22.suse.cz>
 <201502182306.HAB60908.MVQFOHJSOOFLFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502182306.HAB60908.MVQFOHJSOOFLFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

On Wed 18-02-15 23:06:17, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > Because they cannot perform any IO/FS transactions and that would lead
> > > > to a premature OOM conditions way too easily. OOM killer is a _last
> > > > resort_ reclaim opportunity not something that would happen just because
> > > > you happen to be not able to flush dirty pages. 
> > > 
> > > But you should not have applied such change without making necessary
> > > changes to GFP_NOFS / GFP_NOIO users with such expectation and testing
> > > at linux-next.git . Applying such change after 3.19-rc6 is a sucker punch.
> > 
> > This is a nonsense. OOM was disbaled for !__GFP_FS for ages (since
> > before git era).
> >  
> Then, at least I expect that filesystem error actions will not be taken so
> trivially. Can we apply http://marc.info/?l=linux-mm&m=142418465615672&w=2 for
> Linux 3.19-stable?

I do not understand. What kind of bug would be fixed by that change?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
