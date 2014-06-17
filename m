Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8ABBB6B0036
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 21:21:49 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so1415898pdb.7
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 18:21:49 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id eb5si12694419pbc.126.2014.06.16.18.21.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 18:21:48 -0700 (PDT)
Message-ID: <539F97E8.6070607@huawei.com>
Date: Tue, 17 Jun 2014 09:20:40 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] doc: update Documentation/sysctl/vm.txt
References: <539EB803.9070001@huawei.com> <539F21F4.20206@infradead.org>
In-Reply-To: <539F21F4.20206@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, aquini@redhat.com, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On 2014/6/17 0:57, Randy Dunlap wrote:

> On 06/16/14 02:25, Xishi Qiu wrote:
>> Update the doc.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  Documentation/sysctl/vm.txt |   43 +++++++++++++++++++++++++++++++++++++++++++
>>  1 files changed, 43 insertions(+), 0 deletions(-)
>>
>> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
>> index dd9d0e3..8008e53 100644
>> --- a/Documentation/sysctl/vm.txt
>> +++ b/Documentation/sysctl/vm.txt
>> @@ -20,6 +20,10 @@ Currently, these files are in /proc/sys/vm:
>>  
>>  - admin_reserve_kbytes
>>  - block_dump
>> +- cache_limit_mbytes
>> +- cache_limit_ratio
>> +- cache_reclaim_s
>> +- cache_reclaim_weight
>>  - compact_memory
>>  - dirty_background_bytes
>>  - dirty_background_ratio
>> @@ -97,6 +101,45 @@ information on block I/O debugging is in Documentation/laptops/laptop-mode.txt.
>>  
>>  ==============================================================
>>  
>> +cache_limit_mbytes
>> +
>> +This is used to limit page cache amount. The input unit is MB, value range
>> +is from 0 to totalram_pages. If this is set to 0, it will not limit page cache.
> 
> Where does one find the value of totalram_pages?
> 

"cat /proc/meminfo | grep MemTotal" or "free -m"

> Is totalram_pages in MB or does totalram_pages need to be divided by some value
> to convert it to MB?
> 

Yes, should convert it to MB.

Thanks,
Xishi Qiu

>> +When written to the file, cache_limit_ratio will be updated too.
>> +
>> +The default value is 0.
>> +
>> +==============================================================
>> +
>> +cache_limit_ratio
>> +
>> +This is used to limit page cache amount. The input unit is percent, value
>> +range is from 0 to 100. If this is set to 0, it will not limit page cache.
>> +When written to the file, cache_limit_mbytes will be updated too.
>> +
>> +The default value is 0.
>> +
>> +==============================================================
>> +
>> +cache_reclaim_s
>> +
>> +This is used to reclaim page cache in circles. The input unit is second,
>> +the minimum value is 0. If this is set to 0, it will disable the feature.
>> +
>> +The default value is 0.
>> +
>> +==============================================================
>> +
>> +cache_reclaim_weight
>> +
>> +This is used to speed up page cache reclaim. It depend on enabling
> 
>                                                    depends on
> 
>> +cache_limit_mbytes/cache_limit_ratio or cache_reclaim_s. Value range is
>> +from 1(slow) to 100(fast).
>> +
>> +The default value is 1.
>> +
>> +==============================================================
>> +
>>  compact_memory
>>  
>>  Available only when CONFIG_COMPACTION is set. When 1 is written to the file,
>>
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
