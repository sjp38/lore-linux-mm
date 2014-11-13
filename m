Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACD76B00E0
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 08:55:58 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id v63so1111076oia.15
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:55:58 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id y7si29700489oej.107.2014.11.13.05.55.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 05:55:57 -0800 (PST)
Received: by mail-oi0-f50.google.com with SMTP id a141so2156812oig.9
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:55:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141113025337.GA9068@medulla.variantweb.net>
References: <1415532143-4409-1-git-send-email-opensource.ganesh@gmail.com>
	<20141113025337.GA9068@medulla.variantweb.net>
Date: Thu, 13 Nov 2014 21:55:56 +0800
Message-ID: <CADAEsF83UsvEm02zjVtjUt7-kMkKq69xZ8bAAGtHRjAYmXw_SA@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: unregister zswap_cpu_notifier_block in cleanup procedure
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2014-11-13 10:53 GMT+08:00 Seth Jennings <sjennings@variantweb.net>:
> On Sun, Nov 09, 2014 at 07:22:23PM +0800, Mahendran Ganesh wrote:
>> In zswap_cpu_init(), the code does not unregister *zswap_cpu_notifier_block*
>> during the cleanup procedure.
>
> This is not needed.  If we are in the cleanup code, we never got to the
> __register_cpu_notifier() call.

Yes, you are right. Thanks for you review.

>
> Thanks,
> Seth
>
>>
>> This patch fix this issue.
>>
>> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
>> ---
>>  mm/zswap.c |    1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index ea064c1..51a2c45 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -404,6 +404,7 @@ static int zswap_cpu_init(void)
>>  cleanup:
>>       for_each_online_cpu(cpu)
>>               __zswap_cpu_notifier(CPU_UP_CANCELED, cpu);
>> +     __unregister_cpu_notifier(&zswap_cpu_notifier_block);
>>       cpu_notifier_register_done();
>>       return -ENOMEM;
>>  }
>> --
>> 1.7.9.5
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
