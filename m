Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D45C66B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:16:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 77so287784794pgc.5
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:16:59 -0700 (PDT)
Received: from dggrg01-dlp.huawei.com ([45.249.212.187])
        by mx.google.com with ESMTPS id x19si11279834pgj.283.2017.03.13.05.16.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 05:16:58 -0700 (PDT)
Subject: Re: [RFC] mm/compaction: ignore block suitable after check large free
 page
References: <1489119648-59583-1-git-send-email-xieyisheng1@huawei.com>
 <eb3bbece-77ea-b88f-d4bf-dbf9bdf7f413@suse.cz>
 <9104271f-c90f-772c-26b2-410fa8bdfdb0@huawei.com>
 <129003b1-bf1e-db03-6117-59657d2ae0b1@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <b1e2b1a2-936b-8f73-1094-296ac40cc053@huawei.com>
Date: Mon, 13 Mar 2017 20:16:30 +0800
MIME-Version: 1.0
In-Reply-To: <129003b1-bf1e-db03-6117-59657d2ae0b1@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, rientjes@google.com, minchan@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com, liubo95@huawei.com

Hi Vlastimil,

Thanks for comment.
On 2017/3/13 17:51, Vlastimil Babka wrote:
> On 03/10/2017 10:53 AM, Yisheng Xie wrote:
>> Hi Vlastimil,
>>
>> Thanks for comment.
>> On 2017/3/10 15:30, Vlastimil Babka wrote:
>>> On 03/10/2017 05:20 AM, Yisheng Xie wrote:
>>>> If the migrate target is a large free page and we ignore suitable,
>>>> it may not good for defrag. So move the ignore block suitable after
>>>> check large free page.
>>>
>>> Right. But in practice I expect close to no impact, because direct
>>> compaction shouldn't have to be called if there's a >=pageblock_order
>>> page already available.
>>>
>> Maybe you are right and this change is just based on logical analyses.
> 
> I'm not opposing the change, it might be better for future-proofing the
> function, just pointing out that it most likely won't have any visible
> effect right now.
Get it, maybe I should put these in the change log :)

> 
>> Presently, only in direct compaction, we increase the compaction priority,
>> and ignore suitable at MIN_COMPACT_PRIORITY. I have a silly question, can
>> we do the similar thing in kcompactd? maybe by doing most work in kcompactd,
>> we can get better perf of slow path.
> 
> That would need a very good evaluation at the very least. Migrating
> pages into pageblocks other than movable ones brings the danger of later
> unmovable/reclaimable allocations having to fallback to movable
> pageblocks and causing permanent fragmentation. For direct compaction we
> decided that it's better to risk permanent fragmentation than a
> premature OOM, but for kcompactd there doesn't seem to be such
> compelling reason.
Thanks for kindly explain.

> 
>> Thanks
>> Yisheng Xie


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
