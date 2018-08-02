Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF106B000A
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 12:55:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y18-v6so1986689wma.9
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 09:55:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4-v6sor929587wrv.61.2018.08.02.09.55.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 09:55:01 -0700 (PDT)
MIME-Version: 1.0
References: <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
 <CAHbLzkpBnNN4RBMHXzy09x1PZw4m5D99jANmjD=0GT=1tkxniQ@mail.gmail.com>
In-Reply-To: <CAHbLzkpBnNN4RBMHXzy09x1PZw4m5D99jANmjD=0GT=1tkxniQ@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 2 Aug 2018 09:54:49 -0700
Message-ID: <CALvZod6cUJktTAGrc-q7XPRTykdWR6MfgyPXE1B=AZq9U7P31g@mail.gmail.com>
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to do_shrink_slab()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shy828301@gmail.com
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Matthew Wilcox <willy@infradead.org>, jbacik@fb.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 2, 2018 at 9:47 AM Yang Shi <shy828301@gmail.com> wrote:
>
> On Thu, Aug 2, 2018 at 4:00 AM, Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> > In case of shrink_slab_memcg() we do not zero nid, when shrinker
> > is not numa-aware. This is not a real problem, since currently
> > all memcg-aware shrinkers are numa-aware too (we have two:
>
> Actually, this is not true. huge_zero_page_shrinker is NOT numa-aware.
> deferred_split_shrinker is numa-aware.
>

But both huge_zero_page_shrinker and huge_zero_page_shrinker are not
memcg-aware shrinkers. I think Kirill is saying all memcg-aware
shrinkers are also numa-aware shrinkers.

Shakeel
