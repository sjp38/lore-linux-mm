Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43C856B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 04:50:14 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id x63so14868918ioe.18
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 01:50:14 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id s6si7674244ioe.247.2017.11.20.01.50.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 01:50:13 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: Re: [PATCH] kmemcheck: add scheduling point to kmemleak_scan
References: <1510902236-4444-1-git-send-email-xieyisheng1@huawei.com>
 <20171117182722.vhgzd5rj3qgv7a6f@armageddon.cambridge.arm.com>
Message-ID: <5b0d183d-a251-6ee5-7f5c-d58c9b90cd80@huawei.com>
Date: Mon, 20 Nov 2017 17:46:30 +0800
MIME-Version: 1.0
In-Reply-To: <20171117182722.vhgzd5rj3qgv7a6f@armageddon.cambridge.arm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Catalin,

On 2017/11/18 2:27, Catalin Marinas wrote:
> Please fix the subject as the tool is called "kmemleak" rather than
> "kmemcheck".

Yeah, this really is a terrible typo.

> 
> On Fri, Nov 17, 2017 at 03:03:56PM +0800, Yisheng Xie wrote:
>> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>> index e4738d5..e9f2e86 100644
>> --- a/mm/kmemleak.c
>> +++ b/mm/kmemleak.c
>> @@ -1523,6 +1523,8 @@ static void kmemleak_scan(void)
>>  			if (page_count(page) == 0)
>>  				continue;
>>  			scan_block(page, page + 1, NULL);
>> +			if (!(pfn % 1024))
>> +				cond_resched();
> 
> For consistency with the other places where we call cond_resched() in
> kmemleak, I would use MAX_SCAN_SIZE. Something like
> 
> 			if (!(pfn % (MAX_SCAN_SIZE / sizeof(page))))
> 				cont_resched();

Yes, this will keep it consistency with the other places.

I will take both of these suggestion in next version.

Thanks
Yisheng Xie
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
