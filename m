Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E97F8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 11:57:13 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id m16so29115114pgd.0
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 08:57:13 -0800 (PST)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id g15si1694466pgl.141.2019.01.03.08.57.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 08:57:12 -0800 (PST)
Subject: Re: [PATCH 2/3] mm: memcontrol: do not try to do swap when force
 empty
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <1546459533-36247-3-git-send-email-yang.shi@linux.alibaba.com>
 <CALvZod7X6FOMnZT48Q9Joh_nha6NMXntL3XqMDqRYFZ1ULgh=w@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <763b97f5-ea9c-e3e6-7fd9-0ab42cf09ca8@linux.alibaba.com>
Date: Thu, 3 Jan 2019 08:56:30 -0800
MIME-Version: 1.0
In-Reply-To: <CALvZod7X6FOMnZT48Q9Joh_nha6NMXntL3XqMDqRYFZ1ULgh=w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 1/2/19 1:45 PM, Shakeel Butt wrote:
> On Wed, Jan 2, 2019 at 12:06 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>> The typical usecase of force empty is to try to reclaim as much as
>> possible memory before offlining a memcg.  Since there should be no
>> attached tasks to offlining memcg, the tasks anonymous pages would have
>> already been freed or uncharged.
> Anon pages can come from tmpfs files as well.

Yes, but they are charged to swap space as regular anon pages.

>
>> Even though anonymous pages get
>> swapped out, but they still get charged to swap space.  So, it sounds
>> pointless to do swap for force empty.
>>
> I understand that force_empty is typically used before rmdir'ing a
> memcg but it might be used differently by some users. We use this
> interface to test memory reclaim behavior (anon and file).

Thanks for sharing your usecase. So, you uses this for test only?

>
> Anyways, I am not against changing the behavior, we can adapt
> internally but there might be other users using this interface
> differently.

Thanks.

Yang

>
> thanks,
> Shakeel
