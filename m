Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1514F6B007E
	for <linux-mm@kvack.org>; Wed, 11 May 2016 02:01:12 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so27449069lfq.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 23:01:12 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id r129si36462753wma.68.2016.05.10.23.01.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 23:01:10 -0700 (PDT)
Subject: Re: [PATCH] Documentation/memcg: remove restriction of setting kmem
 limit
References: <572B0105.50503@huawei.com> <20160505083221.GD4386@dhcp22.suse.cz>
From: Qiang Huang <h.huangqiang@huawei.com>
Message-ID: <5732C902.8020006@huawei.com>
Date: Wed, 11 May 2016 13:54:10 +0800
MIME-Version: 1.0
In-Reply-To: <20160505083221.GD4386@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: corbet@lwn.net, tj@kernel.org, Zefan Li <lizefan@huawei.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org


On 2016/5/5 16:32, Michal Hocko wrote:
> On Thu 05-05-16 16:15:01, Qiang Huang wrote:
>> We don't have this restriction for a long time, docs should
>> be fixed.
>>
>> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
>> ---
>>  Documentation/cgroup-v1/memory.txt | 8 +++-----
>>  1 file changed, 3 insertions(+), 5 deletions(-)
>>
>> diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
>> index ff71e16..d45b201 100644
>> --- a/Documentation/cgroup-v1/memory.txt
>> +++ b/Documentation/cgroup-v1/memory.txt
>> @@ -281,11 +281,9 @@ different than user memory, since it can't be swapped out, which makes it
>>  possible to DoS the system by consuming too much of this precious resource.
>>  
>>  Kernel memory won't be accounted at all until limit on a group is set. This
>> -allows for existing setups to continue working without disruption.  The limit
>> -cannot be set if the cgroup have children, or if there are already tasks in the
>> -cgroup. Attempting to set the limit under those conditions will return -EBUSY.
>> -When use_hierarchy == 1 and a group is accounted, its children will
>> -automatically be accounted regardless of their limit value.
>> +allows for existing setups to continue working without disruption. When
>> +use_hierarchy == 1 and a group is accounted, its children will automatically
>> +be accounted regardless of their limit value.
> The restriction is not there anymore because the accounting is enabled
> by default even in the cgroup v1 - see b313aeee2509 ("mm: memcontrol:
> enable kmem accounting for all cgroups in the legacy hierarchy"). So
> this _whole_ paragraph could see some update.

Sorry for the delay.
Thanks for the hint, I'll sent a new patch soon.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
