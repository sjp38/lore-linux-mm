Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8D65C6B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 21:47:45 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id x3so87672651obt.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 18:47:45 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id o84si4063310oik.104.2016.03.30.18.47.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Mar 2016 18:47:44 -0700 (PDT)
Subject: Re: [PATCH] Revert "mm/page_alloc: protect pcp->batch accesses with
 ACCESS_ONCE"
References: <1459333327-89720-1-git-send-email-hekuang@huawei.com>
 <20160330103839.GA4773@techsingularity.net> <56FBAFA0.3010604@huawei.com>
 <20160330111044.GA4324@dhcp22.suse.cz> <56FC7A02.1080201@huawei.com>
 <56FC7FD2.9000203@huawei.com>
From: Hekuang <hekuang@huawei.com>
Message-ID: <56FC819C.5010305@huawei.com>
Date: Thu, 31 Mar 2016 09:47:08 +0800
MIME-Version: 1.0
In-Reply-To: <56FC7FD2.9000203@huawei.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zefan Li <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, cody@linux.vnet.ibm.com, gilad@benyossef.com, kosaki.motohiro@gmail.com, mgorman@suse.de, penberg@kernel.org, wangnan0@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

hi

a?? 2016/3/31 9:39, Zefan Li a??e??:
> On 2016/3/31 9:14, Hekuang wrote:
>> Hi
>>
>> a?? 2016/3/30 19:10, Michal Hocko a??e??:
>>> On Wed 30-03-16 18:51:12, Hekuang wrote:
>>>> hi
>>>>
>>>> a?? 2016/3/30 18:38, Mel Gorman a??e??:
>>>>> On Wed, Mar 30, 2016 at 10:22:07AM +0000, He Kuang wrote:
>>>>>> This reverts commit 998d39cb236fe464af86a3492a24d2f67ee1efc2.
>>>>>>
>>>>>> When local irq is disabled, a percpu variable does not change, so we can
>>>>>> remove the access macros and let the compiler optimize the code safely.
>>>>>>
>>>>> batch can be changed from other contexts. Why is this safe?
>>>>>
>>>> I've mistakenly thought that per_cpu variable can only be accessed by that
>>>> cpu.
>>> git blame would point you to 998d39cb236f ("mm/page_alloc: protect
>>> pcp->batch accesses with ACCESS_ONCE"). I haven't looked into the code
>>> deeply to confirm this is still the case but it would be a good lead
>>> that this is not that simple. ACCESS_ONCE resp. {READ,WRITE}_ONCE are
>>> usually quite subtle so I would encourage you or anybody else who try to
>>> remove them to study the code and the history deeper before removing
>>> them.
>>>
>> Thank you for responding, I've read that commit and related articles and not sending
>> mail casually, though you may think it's a stupid patch. I'm a beginner and I think
>> sending mails to maillist is a effective way to learn kernel, And, sure i'll be more careful and
>> well prepared next time :)
>>
> pcp->batch can be changed in a different cpu. You may read percpu_pagelist_fraction_sysctl_handler()
> to see how that can happen.
>
>
OK. got it!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
