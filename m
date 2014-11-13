Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0E25A6B00BE
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 09:16:12 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id v63so1147228oia.29
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 06:16:11 -0800 (PST)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id h9si29864125obe.72.2014.11.13.06.16.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 06:16:10 -0800 (PST)
Received: by mail-oi0-f42.google.com with SMTP id v63so1156124oia.1
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 06:16:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141113025544.GB9068@medulla.variantweb.net>
References: <1415535832-4822-1-git-send-email-opensource.ganesh@gmail.com>
	<20141113025544.GB9068@medulla.variantweb.net>
Date: Thu, 13 Nov 2014 22:16:10 +0800
Message-ID: <CADAEsF-LvMCm0SA4PY4f66rwJGWiyR6OWHG2vaagSPQ1LrQ0GQ@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: add __init to some functions in zswap
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, ddstreet@ieee.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2014-11-13 10:55 GMT+08:00 Seth Jennings <sjennings@variantweb.net>:
> On Sun, Nov 09, 2014 at 08:23:52PM +0800, Mahendran Ganesh wrote:
>> zswap_cpu_init/zswap_comp_exit/zswap_entry_cache_create is only
>> called by __init init_zswap()
>
> Thanks for the cleanup!
>
> Acked-by: Seth Jennings <sjennings@variantweb.net>

Thanks very much!

>
>>
>> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
>> ---
>>  mm/zswap.c |    6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index 51a2c45..2e621fa 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -149,7 +149,7 @@ static int __init zswap_comp_init(void)
>>       return 0;
>>  }
>>
>> -static void zswap_comp_exit(void)
>> +static void __init zswap_comp_exit(void)
>>  {
>>       /* free percpu transforms */
>>       if (zswap_comp_pcpu_tfms)
>> @@ -206,7 +206,7 @@ static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
>>  **********************************/
>>  static struct kmem_cache *zswap_entry_cache;
>>
>> -static int zswap_entry_cache_create(void)
>> +static int __init zswap_entry_cache_create(void)
>>  {
>>       zswap_entry_cache = KMEM_CACHE(zswap_entry, 0);
>>       return zswap_entry_cache == NULL;
>> @@ -389,7 +389,7 @@ static struct notifier_block zswap_cpu_notifier_block = {
>>       .notifier_call = zswap_cpu_notifier
>>  };
>>
>> -static int zswap_cpu_init(void)
>> +static int __init zswap_cpu_init(void)
>>  {
>>       unsigned long cpu;
>>
>> --
>> 1.7.9.5
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
