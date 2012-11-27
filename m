Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 37FE26B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 08:04:59 -0500 (EST)
Message-ID: <50B4B6BE.3000902@cn.fujitsu.com>
Date: Tue, 27 Nov 2012 20:49:02 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <CAA_GA1d7CxHvmZELvD_DO6u5tu1WBqfmLiuEzeFo=xMzuW50Tg@mail.gmail.com> <50B479FA.6010307@cn.fujitsu.com> <CAA_GA1ezZJyqVL=Dp5U2zzNw6bkfMKJY_STkt3E7TXkUYcv+jQ@mail.gmail.com>
In-Reply-To: <CAA_GA1ezZJyqVL=Dp5U2zzNw6bkfMKJY_STkt3E7TXkUYcv+jQ@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, m.szyprowski@samsung.com

On 11/27/2012 08:09 PM, Bob Liu wrote:
> On Tue, Nov 27, 2012 at 4:29 PM, Tang Chen<tangchen@cn.fujitsu.com>  wrote:
>> Hi Liu,
>>
>> This feature is used in memory hotplug.
>>
>> In order to implement a whole node hotplug, we need to make sure the
>> node contains no kernel memory, because memory used by kernel could
>> not be migrated. (Since the kernel memory is directly mapped,
>> VA = PA + __PAGE_OFFSET. So the physical address could not be changed.)
>>
>> User could specify all the memory on a node to be movable, so that the
>> node could be hot-removed.
>>
>
> Thank you for your explanation. It's reasonable.
>
> But i think it's a bit duplicated with CMA, i'm not sure but maybe we
> can combine it with CMA which already in mainline?
>
Hi Liu,

Thanks for your advice. :)

CMA is Contiguous Memory Allocator, right?  What I'm trying to do is
controlling where is the start of ZONE_MOVABLE of each node. Could
CMA do this job ?

And also, after a short investigation, CMA seems need to base on
memblock. But we need to limit memblock not to allocate memory on
ZONE_MOVABLE. As a result, we need to know the ranges before memblock
could be used. I'm afraid we still need an approach to get the ranges,
such as a boot option, or from static ACPI tables such as SRAT/MPST.

I'm don't know much about CMA for now. So if you have any better idea,
please share with us, thanks. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
