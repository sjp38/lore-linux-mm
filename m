Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5415D6B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 22:03:55 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so6707452pad.25
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 19:03:55 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id rk12si18764510pab.127.2014.08.17.19.03.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 17 Aug 2014 19:03:54 -0700 (PDT)
Message-ID: <53F15E33.40705@huawei.com>
Date: Mon, 18 Aug 2014 10:00:19 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mem-hotplug: let memblock skip the hotpluggable memory
 regions in __next_mem_range()
References: <53E8C5AA.5040506@huawei.com> <20140816130456.GH9305@htj.dyndns.org> <53EF6C79.3000603@huawei.com> <20140817110821.GM9305@htj.dyndns.org>
In-Reply-To: <20140817110821.GM9305@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wen
 Congyang <wency@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "H.
 Peter Anvin" <hpa@zytor.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2014/8/17 19:08, Tejun Heo wrote:

> Hello,
> 
> On Sat, Aug 16, 2014 at 10:36:41PM +0800, Xishi Qiu wrote:
>> numa_clear_node_hotplug()? There is only numa_clear_kernel_node_hotplug().
> 
> Yeah, that one.
> 
>> If we don't clear hotpluggable flag in free_low_memory_core_early(), the 
>> memory which marked hotpluggable flag will not free to buddy allocator.
>> Because __next_mem_range() will skip them.
>>
>> free_low_memory_core_early
>> 	for_each_free_mem_range
>> 		for_each_mem_range
>> 			__next_mem_range		
> 
> Ah, okay, so the patch fixes __next_mem_range() and thus makes
> free_low_memory_core_early() to skip hotpluggable regions unlike
> before.  Please explain things like that in the changelog.  Also,

OK, I will send V2.

Thanks,
Xishi Qiu

> what's its relationship with numa_clear_kernel_node_hotplug()?  Do we
> still need them?  If so, what are the different roles that these two
> separate places serve?
> 
> Thanks.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
