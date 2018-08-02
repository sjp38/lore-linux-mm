Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 236646B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 13:26:17 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 17-v6so2649927qkz.15
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 10:26:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10-v6sor1175329qvd.60.2018.08.02.10.26.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 10:26:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALvZod6cUJktTAGrc-q7XPRTykdWR6MfgyPXE1B=AZq9U7P31g@mail.gmail.com>
References: <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
 <CAHbLzkpBnNN4RBMHXzy09x1PZw4m5D99jANmjD=0GT=1tkxniQ@mail.gmail.com> <CALvZod6cUJktTAGrc-q7XPRTykdWR6MfgyPXE1B=AZq9U7P31g@mail.gmail.com>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 2 Aug 2018 10:26:14 -0700
Message-ID: <CAHbLzkpexLdg=eEudwxV-ztF81gs2a4HeyYb2zeAWZmV45ja4w@mail.gmail.com>
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to do_shrink_slab()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Matthew Wilcox <willy@infradead.org>, jbacik@fb.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 2, 2018 at 9:54 AM, Shakeel Butt <shakeelb@google.com> wrote:
> On Thu, Aug 2, 2018 at 9:47 AM Yang Shi <shy828301@gmail.com> wrote:
>>
>> On Thu, Aug 2, 2018 at 4:00 AM, Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>> > In case of shrink_slab_memcg() we do not zero nid, when shrinker
>> > is not numa-aware. This is not a real problem, since currently
>> > all memcg-aware shrinkers are numa-aware too (we have two:
>>
>> Actually, this is not true. huge_zero_page_shrinker is NOT numa-aware.
>> deferred_split_shrinker is numa-aware.
>>
>
> But both huge_zero_page_shrinker and huge_zero_page_shrinker are not
> memcg-aware shrinkers. I think Kirill is saying all memcg-aware
> shrinkers are also numa-aware shrinkers.

Aha, thanks for reminding. Yes, I missed that memcg-aware part.

>
> Shakeel
