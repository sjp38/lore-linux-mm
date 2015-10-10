Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 499726B0255
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 22:21:28 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so102076696pab.3
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 19:21:27 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id yk2si6844902pac.192.2015.10.09.19.21.25
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 19:21:27 -0700 (PDT)
Message-ID: <56187188.4070103@huawei.com>
Date: Sat, 10 Oct 2015 10:01:44 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] mm: Introduce kernelcore=reliable option
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com> <561762DC.3080608@huawei.com> <561787DA.4040809@jp.fujitsu.com> <5617989E.9070700@huawei.com>
In-Reply-To: <5617989E.9070700@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, tony.luck@intel.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, akpm@linux-foundation.org, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, zhongjiang@huawei.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Leon Romanovsky <leon@leon.nu>

On 2015/10/9 18:36, Xishi Qiu wrote:

> On 2015/10/9 17:24, Kamezawa Hiroyuki wrote:
> 
>> On 2015/10/09 15:46, Xishi Qiu wrote:
>>> On 2015/10/9 22:56, Taku Izumi wrote:
>>>
>>>> Xeon E7 v3 based systems supports Address Range Mirroring
>>>> and UEFI BIOS complied with UEFI spec 2.5 can notify which
>>>> ranges are reliable (mirrored) via EFI memory map.
>>>> Now Linux kernel utilize its information and allocates
>>>> boot time memory from reliable region.
>>>>
>>>> My requirement is:
>>>>    - allocate kernel memory from reliable region
>>>>    - allocate user memory from non-reliable region
>>>>
>>>> In order to meet my requirement, ZONE_MOVABLE is useful.
>>>> By arranging non-reliable range into ZONE_MOVABLE,
>>>> reliable memory is only used for kernel allocations.
>>>>

Hi,

If we reuse the movable zone, we should set appropriate size of
mirrored memory region(normal zone) and non-mirrored memory
region(movable zone). In some cases, kernel will take more memory
than user, e.g. some apps run in kernel space, like module.

I think user can set the size in BIOS interface, right?

Thanks,
Xishi Qiu

 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
