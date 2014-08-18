Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9129F6B0036
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 02:21:19 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so7077753pad.41
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 23:21:17 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id kk11si20064704pbd.119.2014.08.17.23.21.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 17 Aug 2014 23:21:16 -0700 (PDT)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4B4D23EE1E2
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 15:21:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 4B690AC038C
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 15:21:13 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F06961DB8038
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 15:21:12 +0900 (JST)
Message-ID: <53F19B4A.5090409@jp.fujitsu.com>
Date: Mon, 18 Aug 2014 15:20:58 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memory-hotplug: add sysfs zones_online_to attribute
References: <1407902811-4873-1-git-send-email-zhenzhang.zhang@huawei.com>  <53EAE534.8030303@huawei.com> <1408138647.26567.42.camel@misato.fc.hp.com> <53F17230.5020409@huawei.com>
In-Reply-To: <53F17230.5020409@huawei.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>, Toshi Kani <toshi.kani@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, n-horiguchi@ah.jp.nec.com, wangnan0@huawei.com, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

(2014/08/18 12:25), Zhang Zhen wrote:
> On 2014/8/16 5:37, Toshi Kani wrote:
>> On Wed, 2014-08-13 at 12:10 +0800, Zhang Zhen wrote:
>>> Currently memory-hotplug has two limits:
>>> 1. If the memory block is in ZONE_NORMAL, you can change it to
>>> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
>>> 2. If the memory block is in ZONE_MOVABLE, you can change it to
>>> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
>>>
>>> With this patch, we can easy to know a memory block can be onlined to
>>> which zone, and don't need to know the above two limits.
>>>
>>> Updated the related Documentation.
>>>
>>> Change v1 -> v2:
>>> - optimize the implementation following Dave Hansen's suggestion
>>>
>>> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
>>> ---
>>>   Documentation/ABI/testing/sysfs-devices-memory |  8 ++++
>>>   Documentation/memory-hotplug.txt               |  4 +-
>>>   drivers/base/memory.c                          | 62 ++++++++++++++++++++++++++
>>>   include/linux/memory_hotplug.h                 |  1 +
>>>   mm/memory_hotplug.c                            |  2 +-
>>>   5 files changed, 75 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
>>> index 7405de2..2b2a1d7 100644
>>> --- a/Documentation/ABI/testing/sysfs-devices-memory
>>> +++ b/Documentation/ABI/testing/sysfs-devices-memory
>>> @@ -61,6 +61,14 @@ Users:		hotplug memory remove tools
>>>   		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils
>>>
>>>

>>> +What:           /sys/devices/system/memory/memoryX/zones_online_to
>>
>> I think this name is a bit confusing.  How about "valid_online_types"?
>>
> Thanks for your suggestion.
>
> This patch has been added to -mm tree.
> If most people think so, i would like to modify the interface name.

I like Toshi's idea (valid_online_types).

Thanks,
Yasuaki Ishimatsu

> If not, let's leave it as it is.
>
> Best regards!
>> Thanks,
>> -Toshi
>>
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
