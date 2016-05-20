Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58D986B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 11:41:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so226436832pfy.2
        for <linux-mm@kvack.org>; Fri, 20 May 2016 08:41:12 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id d62si28579094pfc.214.2016.05.20.08.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 08:41:11 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id c189so43712816pfb.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 08:41:11 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: move page_ext_init after all struct pages are
 initialized
References: <1463696006-31360-1-git-send-email-yang.shi@linaro.org>
 <20160520131649.GC5197@dhcp22.suse.cz>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <f0c27d67-3735-300b-76eb-e49d56ab7a10@linaro.org>
Date: Fri, 20 May 2016 08:41:09 -0700
MIME-Version: 1.0
In-Reply-To: <20160520131649.GC5197@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 5/20/2016 6:16 AM, Michal Hocko wrote:
> On Thu 19-05-16 15:13:26, Yang Shi wrote:
> [...]
>> diff --git a/init/main.c b/init/main.c
>> index b3c6e36..2075faf 100644
>> --- a/init/main.c
>> +++ b/init/main.c
>> @@ -606,7 +606,6 @@ asmlinkage __visible void __init start_kernel(void)
>>  		initrd_start = 0;
>>  	}
>>  #endif
>> -	page_ext_init();
>>  	debug_objects_mem_init();
>>  	kmemleak_init();
>>  	setup_per_cpu_pageset();
>> @@ -1004,6 +1003,8 @@ static noinline void __init kernel_init_freeable(void)
>>  	sched_init_smp();
>>
>>  	page_alloc_init_late();
>> +	/* Initialize page ext after all struct pages are initializaed */
>> +	page_ext_init();
>>
>>  	do_basic_setup();
>
> I might be missing something but don't we have the same problem with
> CONFIG_FLATMEM? page_ext_init_flatmem is called way earlier. Or
> CONFIG_DEFERRED_STRUCT_PAGE_INIT is never enabled for CONFIG_FLATMEM?

Yes, CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on MEMORY_HOTPLUG which 
depends on SPARSEMEM. So, this config is not valid for FLATMEM at all.

Thanks,
Yang

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
