Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 377DB6B0005
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 15:04:41 -0400 (EDT)
Received: by mail-qk0-f171.google.com with SMTP id s68so10894069qkh.3
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 12:04:41 -0700 (PDT)
Received: from smtp-fw-6001.amazon.com (smtp-fw-6001.amazon.com. [52.95.48.154])
        by mx.google.com with ESMTPS id c52si3310844qgc.5.2016.03.23.12.04.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 12:04:40 -0700 (PDT)
Subject: Re: [RFC] high preempt off latency in vfree path
References: <56F1F4A6.2060400@lab126.com>
 <20160323024402.GA27856@tassilo.jf.intel.com>
From: Joel Fernandes <joelaf@lab126.com>
Message-ID: <56F2E895.7080003@lab126.com>
Date: Wed, 23 Mar 2016 12:03:49 -0700
MIME-Version: 1.0
In-Reply-To: <20160323024402.GA27856@tassilo.jf.intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-rt-users@vger.kernel.org, Nick Piggin <npiggin@suse.de>

On 03/22/16 19:44, Andi Kleen wrote:
>> (1)
>> One is we reduce the number of lazy_max_pages (right now its around 32MB per core worth of pages).
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index aa3891e..2720f4f 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -564,7 +564,7 @@ static unsigned long lazy_max_pages(void)
>>
>>          log = fls(num_online_cpus());
>>
>> -       return log * (32UL * 1024 * 1024 / PAGE_SIZE);
>> +       return log * (8UL * 1024 * 1024 / PAGE_SIZE);
>>   }
>
> This seems like the right fix to me.  Perhaps even make it somewhat smaller.
>
> Even on larger systems it's probably fine because they have a lot more
> cores/threads these days, so it will be still sufficiently large.
>

Thanks Andi. I'll post a patch then.

Regards,
Joel

> -Andi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
