Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9241F6B00BE
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 12:28:45 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2978743dak.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 09:28:44 -0800 (PST)
Message-ID: <50C0D5C6.1050305@gmail.com>
Date: Fri, 07 Dec 2012 01:28:38 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] page_alloc: Bootmem limit with movablecore_map
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-6-git-send-email-tangchen@cn.fujitsu.com> <50B36354.7040501@gmail.com> <50B36B54.7050506@cn.fujitsu.com> <50B38F69.6020902@zytor.com> <50B4304F.4070302@cn.fujitsu.com> <50B45021.2000009@zytor.com>
In-Reply-To: <50B45021.2000009@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, wujianguo <wujianguo106@gmail.com>, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, wujianguo@huawei.com, qiuxishi@huawei.com

Hi hpa and Tang,
	How do you think about the attached patches, which reserves memory
for hotplug from memblock/bootmem allocator at early booting stages?
	Logically we split the task into three parts:
1) Provide a mechanism to specify zone_movable[] by kernel parameter.
   Patch 1-4 from Tang achieves this goal by adding "movablecore_map" kernel
   parameter.
2) Reserve memory for hotplug by reusing information provided by "movablecore_map".
   Patch 5 from Tang achieve this goal. And the attached patches provides
   another way to achieve the same goal by calling memblock_reserve() and newly
   introduced memblock interfaces.
3) Automatically reserve memory for hotplug according to firmware provided
   information based on the attached patches.

Regards!
Gerry

On 11/27/2012 01:31 PM, H. Peter Anvin wrote:
> On 11/26/2012 07:15 PM, Wen Congyang wrote:
>>
>> Hi, hpa
>>
>> The problem is that:
>> node1 address rang: [18G, 34G), and the user specifies movable map is [8G, 24G).
>> We don't know node1's address range before numa init. So we can't prevent
>> allocating boot memory in the range [24G, 34G).
>>
>> The movable memory should be classified as a non-RAM type in memblock. What
>> do you want to say? We don't save type in memblock because we only
>> add E820_RAM and E820_RESERVED_KERN to memblock.
>>
> 
> We either need to keep the type or not add it to the memblocks.
> 
>     -hpa
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
