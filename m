Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 73D016B0036
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 05:32:36 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so1736037pad.28
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 02:32:36 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id iw9si5099737pbd.234.2014.06.19.02.32.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 02:32:35 -0700 (PDT)
Message-ID: <53A2ACD1.8020405@huawei.com>
Date: Thu, 19 Jun 2014 17:26:41 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mem-hotplug: replace simple_strtoul() with kstrtoul()
References: <1403151749-14013-1-git-send-email-zhenzhang.zhang@huawei.com> <53A2962B.9070904@huawei.com> <alpine.DEB.2.02.1406190128190.13670@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406190128190.13670@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: nfont@austin.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

On 2014/6/19 16:31, David Rientjes wrote:
> On Thu, 19 Jun 2014, Zhang Zhen wrote:
> 
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index 89f752d..c1b118a 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -406,7 +406,9 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
>>  	int i, ret;
>>  	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;
>>
>> -	phys_addr = simple_strtoull(buf, NULL, 0);
>> +	ret = kstrtoull(buf, 0, phys_addr);
>> +	if (ret)
>> +		return -EINVAL;
>>
>>  	if (phys_addr & ((pages_per_block << PAGE_SHIFT) - 1))
>>  		return -EINVAL;
> 
> Three issues:
> 
>  - this isn't compile tested, one of your parameters to kstrtoull() has 
>    the wrong type,
> 
>  - this disregards the error returned by kstrtoull() and returns -EINVAL 
>    for all possible errors, kstrtoull() returns other errors as well, and
> 
>  - the patch title in the subject line refers to simple_strtoul() and
>    kstrtoul() which do not appear in your patch.
> 
> Please fix issues and resubmit.
> 

Sorry, i had made a silly mistake. I will fix and resubmit.
Thanks!

> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
