Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id CFB5C6B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 19:59:34 -0500 (EST)
Message-ID: <50B41041.6030902@huawei.com>
Date: Tue, 27 Nov 2012 08:58:41 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] page_alloc: Bootmem limit with movablecore_map
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-6-git-send-email-tangchen@cn.fujitsu.com> <50B36354.7040501@gmail.com> <50B36B54.7050506@cn.fujitsu.com> <50B38F69.6020902@zytor.com>
In-Reply-To: <50B38F69.6020902@zytor.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, wujianguo <wujianguo106@gmail.com>, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, qiuxishi@huawei.com

On 2012/11/26 23:48, H. Peter Anvin wrote:

> On 11/26/2012 05:15 AM, Tang Chen wrote:
>>
>> Hi Wu,
>>
>> That is really a problem. And, before numa memory got initialized,
>> memblock subsystem would be used to allocate memory. I didn't find any
>> approach that could fully address it when I making the patches. There
>> always be risk that memblock allocates memory on ZONE_MOVABLE. I think
>> we can only do our best to prevent it from happening.
>>
>> Your patch is very helpful. And after a shot look at the code, it seems
>> that acpi_numa_memory_affinity_init() is an architecture dependent
>> function. Could we do this somewhere which is not depending on the
>> architecture ?
>>
> 
> The movable memory should be classified as a non-RAM type in memblock,
> that way we will not allocate from it early on.
> 
> 	-hpa


yep, we can put movable memory in reserved.regions in memblock.

> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
