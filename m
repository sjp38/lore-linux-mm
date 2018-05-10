Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 023E46B05B2
	for <linux-mm@kvack.org>; Wed,  9 May 2018 22:47:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w14-v6so393319wrk.22
        for <linux-mm@kvack.org>; Wed, 09 May 2018 19:47:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n21sor3530314wmc.50.2018.05.09.19.47.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 19:47:39 -0700 (PDT)
MIME-Version: 1.0
References: <152586686544.3048.15776787801312398314.stgit@localhost.localdomain>
 <152586701534.3048.9132875744525159636.stgit@localhost.localdomain> <20180509155511.9bb3de08b33d617559e5fb3a@linux-foundation.org>
In-Reply-To: <20180509155511.9bb3de08b33d617559e5fb3a@linux-foundation.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 10 May 2018 02:47:27 +0000
Message-ID: <CALvZod4QNfxkhg1x5NyfWjHe+OmK1kVeU-wepKdmDH46n7Ha0Q@mail.gmail.com>
Subject: Re: [PATCH v4 01/13] mm: Assign id to every memcg-aware shrinker
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, mka@chromium.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, chris@chris-wilson.co.uk, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, jbacik@fb.com, linux@roeck-us.net, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, lirongqing@baidu.com, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Wed, May 9, 2018 at 3:55 PM Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Wed, 09 May 2018 14:56:55 +0300 Kirill Tkhai <ktkhai@virtuozzo.com>
wrote:

> > The patch introduces shrinker::id number, which is used to enumerate
> > memcg-aware shrinkers. The number start from 0, and the code tries
> > to maintain it as small as possible.
> >
> > This will be used as to represent a memcg-aware shrinkers in memcg
> > shrinkers map.
> >
> > ...
> >
> > --- a/fs/super.c
> > +++ b/fs/super.c
> > @@ -248,6 +248,9 @@ static struct super_block *alloc_super(struct
file_system_type *type, int flags,
> >       s->s_time_gran = 1000000000;
> >       s->cleancache_poolid = CLEANCACHE_NO_POOL;
> >
> > +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)

> It would be more conventional to do this logic in Kconfig - define a
> new MEMCG_SHRINKER which equals MEMCG && !SLOB.

> This ifdef occurs a distressing number of times in the patchset :( I
> wonder if there's something we can do about that.

> Also, why doesn't it work with slob?  Please describe the issue in the
> changelogs somewhere.

> It's a pretty big patchset.  I *could* merge it up in the hope that
> someone is planning do do a review soon.  But is there such a person?


Hi Andrew, couple of these patches are being reviewed by Vladimir and I
plan to review too by next week. I think we can merge them into mm tree for
more testing and I will also this patch series internally (though I have to
backport them to our kernel for more extensive testing).

thanks,
Shakeel
