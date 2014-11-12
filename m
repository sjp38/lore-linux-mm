Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id A4F136B00EE
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 22:44:02 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id hz20so574257lab.31
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 19:44:01 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id kt1si4917837lac.41.2014.11.11.19.44.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 19:44:01 -0800 (PST)
Message-ID: <5462D71C.4070600@huawei.com>
Date: Wed, 12 Nov 2014 11:42:20 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: remove redundant call of page_to_pfn
References: <1415697184-26409-1-git-send-email-zhenzhang.zhang@huawei.com> <5461D343.60803@huawei.com> <5462D0F5.1050008@jp.fujitsu.com>
In-Reply-To: <5462D0F5.1050008@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, wangnan0@huawei.com

On 2014/11/12 11:16, Yasuaki Ishimatsu wrote:
> (2014/11/11 18:13), Zhang Zhen wrote:
>> The start_pfn can be obtained directly by
>> phys_index << PFN_SECTION_SHIFT.
>>
>> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
>> ---
> 
> The patch looks good to me but I want you to write a purpose of the patch
> to the description for other reviewer.
> 
> Thanks,
> Yasuaki Ishimatsu
> 

Ok, thanks for your review.

>>   drivers/base/memory.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index 7c5d871..85be040 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -228,8 +228,8 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
>>       struct page *first_page;
>>       int ret;
>>
>> -    first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
>> -    start_pfn = page_to_pfn(first_page);
>> +    start_pfn = phys_index << PFN_SECTION_SHIFT;
>> +    first_page = pfn_to_page(start_pfn);
>>
>>       switch (action) {
>>           case MEM_ONLINE:
>>
> 
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
