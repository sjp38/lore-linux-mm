Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 17FE16B0095
	for <linux-mm@kvack.org>; Mon, 18 May 2015 04:29:14 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so139924780pdf.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 01:29:13 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id qj7si14855362pbc.234.2015.05.18.01.29.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 18 May 2015 01:29:13 -0700 (PDT)
Message-ID: <5559A17B.90401@huawei.com>
Date: Mon, 18 May 2015 16:23:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/3] Mirrored memory support for boot time allocations
References: <cover.1423259664.git.tony.luck@intel.com> <55599BAA.20204@huawei.com>
In-Reply-To: <55599BAA.20204@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Xiexiuqi <xiexiuqi@huawei.com>

Add linux-mm@kvack.org

On 2015/5/18 15:58, Xishi Qiu wrote:

> On 2015/2/7 5:54, Tony Luck wrote:
> 
>> Platforms that support a mix of mirrored and regular memory are coming.
>>
>> We'd like to use the mirrored memory for kernel code, data and dynamically
>> allocated data because our machine check recovery code cannot fix problems
>> there.  This series modifies the memblock allocator to comprehend mirrored
>> memory and use it for all boot time allocations.  Later I'll dig into page_alloc.c
>> to put the leftover mirrored memory into a zone to be used for kernel allocation
>> by slab/slob/slub and others.
> 
> Hi Tony,
> 
> Is it means that you will create a new zone to fill mirrored memory, like the
> movable zone, right? 
> I think this will change a lot of code, why not create a new migrate type?
> such as CMA, e.g. MIGRATE_MIRROR
> 
> Thanks,
> Xishi Qiu
> 
>>
>> You'll see why this is just RFC when you get to part 3.
>>
>> Tony Luck (3):
>>   mm/memblock: Add extra "flag" to memblock to allow selection of memory
>>     based on attribute
>>   mm/memblock: Allocate boot time data structures from mirrored memory
>>   x86, mirror: x86 enabling - find mirrored memory ranges and tell
>>     memblock
>>
>>  arch/s390/kernel/crash_dump.c |   4 +-
>>  arch/sparc/mm/init_64.c       |   4 +-
>>  arch/x86/kernel/check.c       |   2 +-
>>  arch/x86/kernel/e820.c        |   2 +-
>>  arch/x86/mm/init_32.c         |   2 +-
>>  arch/x86/mm/memtest.c         |   2 +-
>>  include/linux/memblock.h      |  43 ++++++++++------
>>  mm/cma.c                      |   4 +-
>>  mm/memblock.c                 | 113 ++++++++++++++++++++++++++++++++----------
>>  mm/nobootmem.c                |  12 ++++-
>>  10 files changed, 135 insertions(+), 53 deletions(-)
>>
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
