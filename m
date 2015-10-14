Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 78DC96B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 00:05:13 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so41195047pac.3
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 21:05:13 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id tg4si9992336pab.100.2015.10.13.21.05.11
        for <linux-mm@kvack.org>;
        Tue, 13 Oct 2015 21:05:12 -0700 (PDT)
Message-ID: <561DD40B.5060509@cn.fujitsu.com>
Date: Wed, 14 Oct 2015 12:03:23 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: skip if required_kernelcore is larger than totalpages
References: <5615D311.5030908@huawei.com> <5617e00e.0c5b8c0a.2d0dd.3faa@mx.google.com> <561B0ECD.5000507@huawei.com> <561DC30C.70909@cn.fujitsu.com> <561DCBF9.4050000@huawei.com>
In-Reply-To: <561DCBF9.4050000@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, zhongjiang@huawei.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, tangchen@cn.fujitsu.com


On 10/14/2015 11:28 AM, Xishi Qiu wrote:
> On 2015/10/14 10:50, Tang Chen wrote:
>
>> Hi, Qiu
>>
>> The patch seems OK to me. Only one little concern below.
>>
>> On 10/12/2015 09:37 AM, Xishi Qiu wrote:
>>> On 2015/10/9 23:41, Yasuaki Ishimatsu wrote:
>>>
>>>> On Thu, 8 Oct 2015 10:21:05 +0800
>>>> Xishi Qiu <qiuxishi@huawei.com> wrote:
>>>>
>>>>> If kernelcore was not specified, or the kernelcore size is zero
>>>>> (required_movablecore >= totalpages), or the kernelcore size is larger
>>>> Why does required_movablecore become larger than totalpages, when the
>>>> kernelcore size is zero? I read the code but I could not find that you
>>>> mention.
>>>>
>>> If user only set boot option movablecore, and the value is larger than
>>> totalpages, the calculation of kernelcore is zero, but we can't fill
>>> the zone only with kernelcore, so skip it.
>>>
>>> I have send a patch before this patch.
>>> "fix overflow in find_zone_movable_pfns_for_nodes()"
>>>          ...
>>>            required_movablecore =
>>>                roundup(required_movablecore, MAX_ORDER_NR_PAGES);
>>> +        required_movablecore = min(totalpages, required_movablecore);
>>>            corepages = totalpages - required_movablecore;
>>>          ...
>>
>> So if required_movablecore >= totalpages, there won't be any ZONE_MOVABLE.
>> How about add a warning or debug info to tell the user he has specified a
>> too large movablecore, and it is ignored ?
>>
>> Thanks.
> Yes, but I don't think is is necessary, user should know the total memory
> before he set the boot option.

Well, I'm just thinking if I set a too large movablecore, but I didn't 
realize it.
And when the system boots up, there is no ZONE_MOVABLE. It may confuse me.

Thanks.

>
> Thanks,
> Xishi Qiu
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
