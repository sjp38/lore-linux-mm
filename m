Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB0706B000D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 09:17:00 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21-v6so856835edp.23
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 06:17:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10-v6si3707265edd.212.2018.08.08.06.16.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 06:16:59 -0700 (PDT)
Date: Wed, 8 Aug 2018 15:16:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, oom: be careful about races when warning about no
 reclaimable task
Message-ID: <20180808131658.GP27972@dhcp22.suse.cz>
References: <20180807072553.14941-1-mhocko@kernel.org>
 <863d73ce-fae9-c117-e361-12c415c787de@i-love.sakura.ne.jp>
 <20180807201935.GB4251@cmpxchg.org>
 <1308e0bd-e194-7b35-484c-fc18f493f8da@i-love.sakura.ne.jp>
 <9cea37c8-ab90-2fdf-395c-efe52ff07072@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9cea37c8-ab90-2fdf-395c-efe52ff07072@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>

On Wed 08-08-18 21:57:13, Tetsuo Handa wrote:
[...]
> Also, before the OOM reaper was introduced, we waited until TIF_MEMDIE is
> cleared from the OOM victim thread. Compared to pre OOM reaper era, giving up
> so early is certainly a regression.

We did clear TIF_MEMDIE flag after mmput() in do_exit so this was not a silver
bullet either. Any reference on the mm_struct would lead to a similar
problem. So could you please stop making strong stamements and start
being reasonable?

Yeah, this is racy. Nobody is claiming otherwise. All we are trying to
say is that this area is full of dragons and before we start making it
more complicating by covering weird cornercases we really need to see
that those corner cases happen in real workloads. Otherwise we end up
with a unmaintainable and fragile mess.

And more importantly this is _not_ what this patch is trying to address
so please do not go tangent again.

I really do not know how to send this simply message to you. I have
tried so many times before.

-- 
Michal Hocko
SUSE Labs
