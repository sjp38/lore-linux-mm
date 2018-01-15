Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 161756B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 07:30:53 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id e29so3869313plj.12
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 04:30:53 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20122.outbound.protection.outlook.com. [40.107.2.122])
        by mx.google.com with ESMTPS id w10si8186623pgp.178.2018.01.15.04.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 04:30:52 -0800 (PST)
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
 <20180110124317.28887-1-aryabinin@virtuozzo.com>
 <20180111104239.GZ1732@dhcp22.suse.cz>
 <4a8f667d-c2ae-e3df-00fd-edc01afe19e1@virtuozzo.com>
 <20180111124629.GA1732@dhcp22.suse.cz>
 <ce885a69-67af-5f4c-1116-9f6803fb45ee@virtuozzo.com>
 <20180111162947.GG1732@dhcp22.suse.cz>
 <560a77b5-02d7-cbae-35f3-0b20a1c384c2@virtuozzo.com>
 <20180112122405.GK1732@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <7d1b5bfb-f602-8cf4-2de6-dd186484e55c@virtuozzo.com>
Date: Mon, 15 Jan 2018 15:30:59 +0300
MIME-Version: 1.0
In-Reply-To: <20180112122405.GK1732@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>



On 01/12/2018 03:24 PM, Michal Hocko wrote:
> On Fri 12-01-18 00:59:38, Andrey Ryabinin wrote:
>> On 01/11/2018 07:29 PM, Michal Hocko wrote:
> [...]
>>> I do not think so. Consider that this reclaim races with other
>>> reclaimers. Now you are reclaiming a large chunk so you might end up
>>> reclaiming more than necessary. SWAP_CLUSTER_MAX would reduce the over
>>> reclaim to be negligible.
>>>
>>
>> I did consider this. And I think, I already explained that sort of race in previous email.
>> Whether "Task B" is really a task in cgroup or it's actually a bunch of reclaimers,
>> doesn't matter. That doesn't change anything.
> 
> I would _really_ prefer two patches here. The first one removing the
> hard coded reclaim count. That thing is just dubious at best. If you
> _really_ think that the higher reclaim target is meaningfull then make
> it a separate patch. I am not conviced but I will not nack it it either.
> But it will make our life much easier if my over reclaim concern is
> right and we will need to revert it. Conceptually those two changes are
> independent anywa.
> 

Ok, fair point. But what about livelock than? Don't you think that we should
go back to something like in V1 patch to prevent it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
