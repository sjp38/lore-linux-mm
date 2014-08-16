Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 01EEB6B0036
	for <linux-mm@kvack.org>; Sat, 16 Aug 2014 10:40:51 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pv20so3183586lab.29
        for <linux-mm@kvack.org>; Sat, 16 Aug 2014 07:40:51 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id l6si17224164lbr.4.2014.08.16.07.40.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 16 Aug 2014 07:40:50 -0700 (PDT)
Message-ID: <53EF6C79.3000603@huawei.com>
Date: Sat, 16 Aug 2014 22:36:41 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mem-hotplug: let memblock skip the hotpluggable memory
 regions in __next_mem_range()
References: <53E8C5AA.5040506@huawei.com> <20140816130456.GH9305@htj.dyndns.org>
In-Reply-To: <20140816130456.GH9305@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wen
 Congyang <wency@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "H.
 Peter Anvin" <hpa@zytor.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2014/8/16 21:04, Tejun Heo wrote:

> On Mon, Aug 11, 2014 at 09:31:22PM +0800, Xishi Qiu wrote:
>> Let memblock skip the hotpluggable memory regions in __next_mem_range(),
>> it is used to to prevent memblock from allocating hotpluggable memory 
>> for the kernel at early time. The code is the same as __next_mem_range_rev().
>>
>> Clear hotpluggable flag before releasing free pages to the buddy allocator.
> 
> Please try to explain "why" in addition to "what".  Why do we need to
> clear hotpluggable flag in free_low_memory_core_early() in addition to
> numa_clear_node_hotplug() in x86 numa.c?  Does this make x86 code
> redundant?  If not, why?
> 

Hi Tejun,

numa_clear_node_hotplug()? There is only numa_clear_kernel_node_hotplug().

If we don't clear hotpluggable flag in free_low_memory_core_early(), the 
memory which marked hotpluggable flag will not free to buddy allocator.
Because __next_mem_range() will skip them.

free_low_memory_core_early
	for_each_free_mem_range
		for_each_mem_range
			__next_mem_range		

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
