Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2679C831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 14:05:53 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id h21so93971962ywc.4
        for <linux-mm@kvack.org>; Mon, 22 May 2017 11:05:53 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id z132si6275907ybb.19.2017.05.22.11.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 11:05:52 -0700 (PDT)
Received: by mail-qk0-x22e.google.com with SMTP id u75so112577654qka.3
        for <linux-mm@kvack.org>; Mon, 22 May 2017 11:05:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ecd4a7ea-06c0-f549-a1bf-6d2d3c0af719@yandex-team.ru>
References: <149520375057.74196.2843113275800730971.stgit@buzz>
 <CALo0P1123MROxgveCdX6YFpWDwG4qrAyHu3Xd1F+ckaFBnF4dQ@mail.gmail.com> <ecd4a7ea-06c0-f549-a1bf-6d2d3c0af719@yandex-team.ru>
From: Roman Guschin <guroan@gmail.com>
Date: Mon, 22 May 2017 19:05:51 +0100
Message-ID: <CALo0P10LM4LYWidrNKGkw=6Bcrq198gmwPbpUBD7yt4C=jJ0pQ@mail.gmail.com>
Subject: Re: [PATCH] mm/oom_kill: count global and memory cgroup oom kills
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

2017-05-22 10:11 GMT+01:00 Konstantin Khlebnikov <khlebnikov@yandex-team.ru>:
>
>
> On 19.05.2017 19:34, Roman Guschin wrote:
>>
>> 2017-05-19 15:22 GMT+01:00 Konstantin Khlebnikov
>> <khlebnikov@yandex-team.ru>:
>>  From a user's point of view the difference between "oom" and "max"
>> becomes really vague here,
>> assuming that "max" is described almost in the same words:
>>
>> "The number of times the cgroup's memory usage was
>> about to go over the max boundary.  If direct reclaim
>> fails to bring it down, the OOM killer is invoked."
>>
>> I wonder, if it's better to fix the existing "oom" value  to show what
>> it has to show, according to docs,
>> rather than to introduce a new one?
>>
>
> Nope, they are different. I think we should rephase documentation somehow
>
> low - count of reclaims below low level
> high - count of post-allocation reclaims above high level
> max - count of direct reclaims
> oom - count of failed direct reclaims
> oom_kill - count of oom killer invocations and killed processes

Definitely worth it.

Also, I would prefer to reserve "oom" for number of oom victims,
and introduce something like "reclaim_failed".
It will be consistent with existing vmstat.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
