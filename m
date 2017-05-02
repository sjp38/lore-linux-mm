Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 94A706B0350
	for <linux-mm@kvack.org>; Tue,  2 May 2017 05:34:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id z129so1003960wmb.23
        for <linux-mm@kvack.org>; Tue, 02 May 2017 02:34:18 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id j16si19529732wrb.230.2017.05.02.02.34.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 02:34:17 -0700 (PDT)
Message-ID: <590851CC.2070402@huawei.com>
Date: Tue, 2 May 2017 17:30:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] dev/mem: "memtester -p 0x6c80000000000 10G" cause crash
References: <59083C5B.5080204@huawei.com> <20170502084323.GG14593@dhcp22.suse.cz> <590848B0.2000801@huawei.com> <20170502091630.GH14593@dhcp22.suse.cz>
In-Reply-To: <20170502091630.GH14593@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shakeel Butt <shakeelb@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On 2017/5/2 17:16, Michal Hocko wrote:

> On Tue 02-05-17 16:52:00, Xishi Qiu wrote:
>> On 2017/5/2 16:43, Michal Hocko wrote:
>>
>>> On Tue 02-05-17 15:59:23, Xishi Qiu wrote:
>>>> Hi, I use "memtester -p 0x6c80000000000 10G" to test physical address 0x6c80000000000
>>>> Because this physical address is invalid, and valid_mmap_phys_addr_range()
>>>> always return 1, so it causes crash.
>>>>
>>>> My question is that should the user assure the physical address is valid?
>>>
>>> We already seem to be checking range_is_allowed(). What is your
>>> CONFIG_STRICT_DEVMEM setting? The code seems to be rather confusing but
>>> my assumption is that you better know what you are doing when mapping
>>> this file.
>>>
>>
>> HI Michal,
>>
>> CONFIG_STRICT_DEVMEM=y, and range_is_allowed() will skip memory, but
>> 0x6c80000000000 is not memory, it is just a invalid address, so it cause
>> crash. 
> 
> OK, I only now looked at the value. It is beyond addressable limit
> (for 47b address space). None of the checks seems to stop this because
> range_is_allowed() resp. its devmem_is_allowed() will allow it as a
> non RAM (!page_is_ram check). I am not really sure how to fix this or
> whether even we should try to fix this particular problem. As I've said
> /dev/mem is dangerous and you should better know what you are doing when
> accessing it.
> 

OK, I know, thank you!

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
