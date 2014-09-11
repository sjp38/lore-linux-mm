Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9256B0035
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 21:08:54 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so13335597pdj.38
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 18:08:54 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id r1si29916917pdl.121.2014.09.10.18.08.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 18:08:53 -0700 (PDT)
Message-ID: <5410F5D5.8060403@huawei.com>
Date: Thu, 11 Sep 2014 09:07:33 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: fix below build warning
References: <1410228703-2496-1-git-send-email-zhenzhang.zhang@huawei.com> <alpine.DEB.2.02.1409101153340.27173@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1409101153340.27173@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, wangnan0@huawei.com

On 2014/9/11 2:55, David Rientjes wrote:
> On Tue, 9 Sep 2014, Zhang Zhen wrote:
> 
>> drivers/base/memory.c: In function 'show_valid_zones':
>> drivers/base/memory.c:384:22: warning: unused variable 'zone_prev' [-Wunused-variable]
>>   struct zone *zone, *zone_prev;
>>                       ^
>>
>> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
> 
> This is
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> on August 29 to this mailing list.
> 
>> ---
>>  drivers/base/memory.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index efd456c..7c5d871 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -381,7 +381,7 @@ static ssize_t show_valid_zones(struct device *dev,
>>  	unsigned long start_pfn, end_pfn;
>>  	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
>>  	struct page *first_page;
>> -	struct zone *zone, *zone_prev;
>> +	struct zone *zone;
>>  
>>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>>  	end_pfn = start_pfn + nr_pages;
> 
> Looks good, but this should already be fixed by
> http://ozlabs.org/~akpm/mmotm/broken-out/memory-hotplug-add-sysfs-zones_online_to-attribute-fix-3-fix.patch
> right?
> 
Yeah, thanks!
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
