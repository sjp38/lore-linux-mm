Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF6C96B0269
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 03:11:41 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e14-v6so3567311qtp.17
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 00:11:41 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0096.outbound.protection.outlook.com. [104.47.2.96])
        by mx.google.com with ESMTPS id k85-v6si4170461qkh.357.2018.08.03.00.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Aug 2018 00:11:40 -0700 (PDT)
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to
 do_shrink_slab()
References: <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
 <CAHbLzkpBnNN4RBMHXzy09x1PZw4m5D99jANmjD=0GT=1tkxniQ@mail.gmail.com>
 <CALvZod6cUJktTAGrc-q7XPRTykdWR6MfgyPXE1B=AZq9U7P31g@mail.gmail.com>
 <CAHbLzkpexLdg=eEudwxV-ztF81gs2a4HeyYb2zeAWZmV45ja4w@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <58099219-edd1-e855-4660-30de1e1b16fb@virtuozzo.com>
Date: Fri, 3 Aug 2018 10:11:32 +0300
MIME-Version: 1.0
In-Reply-To: <CAHbLzkpexLdg=eEudwxV-ztF81gs2a4HeyYb2zeAWZmV45ja4w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>, Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Matthew Wilcox <willy@infradead.org>, jbacik@fb.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 02.08.2018 20:26, Yang Shi wrote:
> On Thu, Aug 2, 2018 at 9:54 AM, Shakeel Butt <shakeelb@google.com> wrote:
>> On Thu, Aug 2, 2018 at 9:47 AM Yang Shi <shy828301@gmail.com> wrote:
>>>
>>> On Thu, Aug 2, 2018 at 4:00 AM, Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>>> In case of shrink_slab_memcg() we do not zero nid, when shrinker
>>>> is not numa-aware. This is not a real problem, since currently
>>>> all memcg-aware shrinkers are numa-aware too (we have two:
>>>
>>> Actually, this is not true. huge_zero_page_shrinker is NOT numa-aware.
>>> deferred_split_shrinker is numa-aware.
>>>
>>
>> But both huge_zero_page_shrinker and huge_zero_page_shrinker are not
>> memcg-aware shrinkers. I think Kirill is saying all memcg-aware
>> shrinkers are also numa-aware shrinkers.
> 
> Aha, thanks for reminding. Yes, I missed that memcg-aware part.

Yes, I mean workingset_shadow_shrinker.
