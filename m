Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33D88280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:49:53 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id z142so6447359itc.6
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 01:49:53 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id u185si1948910ioe.331.2018.01.17.01.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 01:49:52 -0800 (PST)
Message-ID: <5A5F1C09.9040000@huawei.com>
Date: Wed, 17 Jan 2018 17:48:57 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: why vfree() do not free page table memory?
References: <5A4603AB.8060809@huawei.com> <0ffd113e-84da-bd49-2b63-3d27d2702580@suse.cz>
In-Reply-To: <0ffd113e-84da-bd49-2b63-3d27d2702580@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Wujiangtao (A)" <wu.wujiangtao@huawei.com>

On 2018/1/17 17:16, Vlastimil Babka wrote:

> On 12/29/2017 09:58 AM, Xishi Qiu wrote:
>> When calling vfree(), it calls unmap_vmap_area() to clear page table,
>> but do not free the memory of page table, why? just for performance?
> 
> I guess it's expected that the free virtual range and associated page
> tables it might be reused later.
> 

Hi Vlastimili 1/4 ?

If use vmalloc/vfree different size, then there will be some hols during 
VMALLOC_START to VMALLOC_END, and this holes takes page table memory, right?

>> If a driver use vmalloc() and vfree() frequently, we will lost much
>> page table memory, maybe oom later.
> 
> If it's reused, then not really.
> 
> Did you notice an actual issue, or is this just theoretical concern.
> 

Yes, we have this problem on our production line.
I find the page table memory takes 200-300M.

Thanks,
Xishi Qiu

>> Thanks,
>> Xishi Qiu
>>
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
