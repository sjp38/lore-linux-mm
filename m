Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52C3B6B02EE
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 11:01:32 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id x6so2489193plr.7
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:01:32 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00098.outbound.protection.outlook.com. [40.107.0.98])
        by mx.google.com with ESMTPS id g4-v6si240724plo.122.2018.02.22.08.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 08:01:31 -0800 (PST)
Subject: Re: [PATCH v5 2/2] mm/memcontrol.c: Reduce reclaim retries in
 mem_cgroup_resize_limit()
References: <20180119132544.19569-2-aryabinin@virtuozzo.com>
 <20180119133510.GD6584@dhcp22.suse.cz>
 <CALvZod7HS6P0OU6Rps8JeMJycaPd4dF5NjxV8k1y2-yosF2bdA@mail.gmail.com>
 <20180119151118.GE6584@dhcp22.suse.cz>
 <20180221121715.0233d34dda330c56e1a9db5f@linux-foundation.org>
 <f3893181-67a4-aec2-9514-f141fa78a6c0@virtuozzo.com>
 <20180222140932.GL30681@dhcp22.suse.cz>
 <e0705720-0909-e224-4bdd-481660e516f2@virtuozzo.com>
 <20180222153343.GN30681@dhcp22.suse.cz>
 <0927bcab-7e2c-c6f9-d16a-315ac436ba98@virtuozzo.com>
 <20180222154435.GO30681@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <bf4a40fb-0a24-bfcb-124f-15e5e2f87b67@virtuozzo.com>
Date: Thu, 22 Feb 2018 19:01:58 +0300
MIME-Version: 1.0
In-Reply-To: <20180222154435.GO30681@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>



On 02/22/2018 06:44 PM, Michal Hocko wrote:
> On Thu 22-02-18 18:38:11, Andrey Ryabinin wrote:

>>>>
>>>> with the patch:
>>>> best: 1.04  secs, 9.7G reclaimed
>>>> worst: 2.2 secs, 16G reclaimed.
>>>>
>>>> without:
>>>> best: 5.4 sec, 35G reclaimed
>>>> worst: 22.2 sec, 136G reclaimed
>>>
>>> Could you also compare how much memory do we reclaim with/without the
>>> patch?
>>>
>>
>> I did and I wrote the results. Please look again.
> 
> I must have forgotten. Care to point me to the message-id?

The results are quoted right above, literally above. Raise your eyes up. message-id 0927bcab-7e2c-c6f9-d16a-315ac436ba98@virtuozzo.com

I write it here again:

with the patch:
 best: 9.7G reclaimed
 worst: 16G reclaimed

without:
 best: 35G reclaimed
 worst: 136G reclaimed

Or you asking about something else? If so, I don't understand what you want.

> 20180119132544.19569-2-aryabinin@virtuozzo.com doesn't contain this
> information and a quick glance over the follow up thread doesn't have
> anything as well. Ideally, this should be in the patch changelog, btw.
> 

Well, I did these measurements only today and I don't have time machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
