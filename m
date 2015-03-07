Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2A16B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 23:31:20 -0500 (EST)
Received: by igal13 with SMTP id l13so8822865iga.5
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 20:31:20 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id b32si786780iod.34.2015.03.06.20.30.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Mar 2015 20:31:19 -0800 (PST)
Message-ID: <54FA7DD8.9010008@huawei.com>
Date: Sat, 7 Mar 2015 12:26:00 +0800
From: shengyong <shengyong1@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/2] mem-hotplug: introduce sysfs `range' attribute
References: <1425269100-15842-1-git-send-email-shengyong1@huawei.com> <20150302091714.GA32186@hori1.linux.bs1.fc.nec.co.jp> <54F457A5.3070602@huawei.com>
In-Reply-To: <54F457A5.3070602@huawei.com>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "nfont@austin.ibm.com" <nfont@austin.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, Dave Hansen <dave.hansen@intel.com>, David
 Rientjes <rientjes@google.com>

Ping.

The original thoughts of this interface is to get the real size of the section.
Then I thought it maybe more useful if it gives the address range of the section,
so that we can know where the hole is. As Naoya said, I didn't consider NUMA
situation. So if the interface helps, I could try to cover NUMA stuff in it.

thanks,
Sheng

在 2015/3/2 20:29, shengyong 写道:
> 
> 
> 在 2015/3/2 17:17, Naoya Horiguchi 写道:
>> # Cced some people maybe interested in this topic.
>>
>> On Mon, Mar 02, 2015 at 04:04:59AM +0000, Sheng Yong wrote:
>>> There may be memory holes in a memory section, and because of that we can
>>> not know the real size of the section. In order to know the physical memory
>>> area used int one memory section, we walks through iomem resources and
>>> report the memory range in /sys/devices/system/memory/memoryX/range, like,
>>>
>>> root@ivybridge:~# cat /sys/devices/system/memory/memory0/range
>>> 00001000-0008efff
>>> 00090000-0009ffff
>>> 00100000-07ffffff
>>>
>>> Signed-off-by: Sheng Yong <shengyong1@huawei.com>
>>
>> About a year ago, there was a similar request/suggestion from a library
>> developer about exporting valid physical address range
>> (http://thread.gmane.org/gmane.linux.kernel.mm/115600).
>> Then, we tried some but didn't make it.
> Thanks for your information.
>>
>> So if you try to solve this, please consider some points from that discussion:
>> - interface name: just 'range' might not be friendly, if the interface returns
>>   physicall address range, something like 'phys_addr_range' looks better.
>> - prefix '0x': if you display the value range in hex, prefixing '0x' might
>>   be better to avoid letting every parser to add it in itself.
> I agree on these 2 suggestion.
>> - supporting node range: your patch is now just for memory block interface, but
>>   someone (like me) are interested in exporting easy "phys_addr <=> node number"
>>   mapping, so if your approach is easily extensible to node interface, it would
>>   be very nice to include node interface support too.
> After reading the previous discussion, I think the content in the interface should
> look like "<node id> <start-end>" to avoid overlay of memory node. Am I right? Then
> we could use `memory_add_physaddr_to_nid(u64 start)' to translate physical address
> to node id when the address is recorded to the ranges list in get_range().
> The problem is that `struct resource' does not have an appropriate member to save
> the node id value, which is saved in resource->flags temporarily for testing.
> 
> thanks,
> Sheng
>>
>> Thanks,
>> Naoya Horiguchi
>> .
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
