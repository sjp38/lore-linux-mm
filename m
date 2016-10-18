Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 61EFC6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 22:57:20 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ry6so220769501pac.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 19:57:20 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id m2si29886950pgd.289.2016.10.17.19.57.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 19:57:19 -0700 (PDT)
Subject: Re: [PATCH vmalloc] reduce purge_lock range and hold time of
References: <1476540769-31893-1-git-send-email-zhouxianrong@huawei.com>
 <20161015165521.GB31568@infradead.org>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <a33c5cd3-ce94-b333-af3d-d8fc2b0765e1@huawei.com>
Date: Tue, 18 Oct 2016 10:55:26 +0800
MIME-Version: 1.0
In-Reply-To: <20161015165521.GB31568@infradead.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, chris@chris-wilson.co.uk, vdavydov.dev@gmail.com, mgorman@techsingularity.net, joe@perches.com, shawn.lin@rock-chips.com, iamjoonsoo.kim@lge.com, kuleshovmail@gmail.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

hey Hellwig:
	cond_resched_lock is a good choice. i mixed the cond_resched_lock and batch to balance of
realtime and performance and resubmit this patch.

On 2016/10/16 0:55, Christoph Hellwig wrote:
> On Sat, Oct 15, 2016 at 10:12:48PM +0800, zhouxianrong@huawei.com wrote:
>> From: z00281421 <z00281421@notesmail.huawei.com>
>>
>> i think no need to place __free_vmap_area loop in purge_lock;
>> _free_vmap_area could be non-atomic operations with flushing tlb
>> but must be done after flush tlb. and the whole__free_vmap_area loops
>> also could be non-atomic operations. if so we could improve realtime
>> because the loop times sometimes is larg and spend a few time.
>
> Right, see the previous patch in reply to Joel that drops purge_lock
> entirely.
>
> Instead of your open coded batch counter you probably want to add
> a cond_resched_lock after the call to __free_vmap_area.
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
