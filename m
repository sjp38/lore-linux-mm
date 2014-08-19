Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDD66B0035
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 21:46:14 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so8771098pad.8
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 18:46:14 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id iw8si24329356pbc.127.2014.08.18.18.46.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 18 Aug 2014 18:46:14 -0700 (PDT)
Message-ID: <53F2ABD0.1010706@huawei.com>
Date: Tue, 19 Aug 2014 09:43:44 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memory-hotplug: add sysfs zones_online_to attribute
References: <1407902811-4873-1-git-send-email-zhenzhang.zhang@huawei.com> <53EAE534.8030303@huawei.com> <alpine.DEB.2.02.1408181447260.4796@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1408181447260.4796@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, toshi.kani@hp.com, isimatu.yasuaki@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com, wangnan0@huawei.com, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 2014/8/19 5:48, David Rientjes wrote:
> On Wed, 13 Aug 2014, Zhang Zhen wrote:
> 
>> Currently memory-hotplug has two limits:
>> 1. If the memory block is in ZONE_NORMAL, you can change it to
>> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
>> 2. If the memory block is in ZONE_MOVABLE, you can change it to
>> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
>>
>> With this patch, we can easy to know a memory block can be onlined to
>> which zone, and don't need to know the above two limits.
>>
>> Updated the related Documentation.
>>
>> Change v1 -> v2:
>> - optimize the implementation following Dave Hansen's suggestion
>>
>> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
> 
> linux-next build failure:
> 
> drivers/built-in.o: In function `show_zones_online_to':
> memory.c:(.text+0x13ee09): undefined reference to `test_pages_in_a_zone'
> 
The function implementation in mm/memory_hotplug.c is only built if
CONFIG_MEMORY_HOTREMOVE is enabled.

A fix has been proposed.
http://ozlabs.org/~akpm/mmots/broken-out/memory-hotplug-add-sysfs-zones_online_to-attribute-fix-2.patch

Thanks!
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
