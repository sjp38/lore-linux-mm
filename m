Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CDD266B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:26:18 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p5so28762952pgn.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 10:26:18 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id z6si8006074plo.602.2017.09.27.10.26.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 10:26:16 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
 <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
 <20170927104537.r42javxhnyqlxnqm@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <ae112574-93c4-22a4-1309-58e585f31493@alibaba-inc.com>
Date: Thu, 28 Sep 2017 01:25:50 +0800
MIME-Version: 1.0
In-Reply-To: <20170927104537.r42javxhnyqlxnqm@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/27/17 3:45 AM, Michal Hocko wrote:
> On Wed 27-09-17 08:53:35, Yang Shi wrote:
>> Kernel may panic when oom happens without killable process sometimes it
>> is caused by huge unreclaimable slabs used by kernel.
>>
>> Although kdump could help debug such problem, however, kdump is not
>> available on all architectures and it might be malfunction sometime.
>> And, since kernel already panic it is worthy capturing such information
>> in dmesg to aid touble shooting.
>>
>> Print out unreclaimable slab info (used size and total size) which
>> actual memory usage is not zero (num_objs * size != 0) when:
>>    - unreclaimable slabs : all user memory > unreclaim_slabs_oom_ratio
>>    - panic_on_oom is set or no killable process
> 
> OK, this is better but I do not see why this should be tunable via proc.

Just thought someone might want to dump unreclaimable slab info 
unconditionally.

> Can we start with simple NR_SLAB_UNRECLAIMABLE > LRU_PAGES and place it
> into dump_header so that we get the report also during regular OOM
Yes.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
