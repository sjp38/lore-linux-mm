Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 808C66B0069
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 11:45:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p87so12840419pfj.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 08:45:27 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTPS id v63si6068361pfi.171.2017.10.02.08.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 08:45:26 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
 <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
 <20170927104537.r42javxhnyqlxnqm@dhcp22.suse.cz>
 <ae112574-93c4-22a4-1309-58e585f31493@alibaba-inc.com>
 <20171002072607.sjikpsoaiyebmukd@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <e0812074-0b4f-bba1-ccea-a82c9312da44@alibaba-inc.com>
Date: Mon, 02 Oct 2017 23:44:55 +0800
MIME-Version: 1.0
In-Reply-To: <20171002072607.sjikpsoaiyebmukd@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/2/17 12:26 AM, Michal Hocko wrote:
> On Thu 28-09-17 01:25:50, Yang Shi wrote:
>>
>>
>> On 9/27/17 3:45 AM, Michal Hocko wrote:
>>> On Wed 27-09-17 08:53:35, Yang Shi wrote:
>>>> Kernel may panic when oom happens without killable process sometimes it
>>>> is caused by huge unreclaimable slabs used by kernel.
>>>>
>>>> Although kdump could help debug such problem, however, kdump is not
>>>> available on all architectures and it might be malfunction sometime.
>>>> And, since kernel already panic it is worthy capturing such information
>>>> in dmesg to aid touble shooting.
>>>>
>>>> Print out unreclaimable slab info (used size and total size) which
>>>> actual memory usage is not zero (num_objs * size != 0) when:
>>>>     - unreclaimable slabs : all user memory > unreclaim_slabs_oom_ratio
>>>>     - panic_on_oom is set or no killable process
>>>
>>> OK, this is better but I do not see why this should be tunable via proc.
>>
>> Just thought someone might want to dump unreclaimable slab info
>> unconditionally.
> 
> If that ever happens then we will eventually add it. But do not add proc
> knobs for theoretical usecases. We will have to maintain them and it
> can turn into a maint. pain. Like some others in the past.

It has been removed since v8. Currently the only condition is 
unreclaimable slabs > user memory.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
