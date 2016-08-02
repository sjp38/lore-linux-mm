Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84A126B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 21:45:03 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u142so336512438oia.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 18:45:03 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id t16si51107ota.66.2016.08.01.18.45.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 18:45:02 -0700 (PDT)
Message-ID: <579FFA39.7070902@huawei.com>
Date: Tue, 2 Aug 2016 09:41:13 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add restriction when memory_hotplug config enable
References: <1470063651-29519-1-git-send-email-zhongjiang@huawei.com> <20160801125417.ece9c623f03d952a60113a3f@linux-foundation.org>
In-Reply-To: <20160801125417.ece9c623f03d952a60113a3f@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On 2016/8/2 3:54, Andrew Morton wrote:
> On Mon, 1 Aug 2016 23:00:51 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
>
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> At present, It is obvious that memory online and offline will fail
>> when KASAN enable,
> huh, I didn't know that.  What's the problem and are there plans to fix it?
   when I  test the memory hotplug function.  The memory online and offline always fails.
   because I forget the turn off  the KASAN config.  I know it is not compatible with hotplug.
   In fact,  but I always forget to do so.  
>>  therefore, it is necessary to add the condition
>> to limit the memory_hotplug when KASAN enable.
>>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/Kconfig | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 3e2daef..f6dd77e 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -187,6 +187,7 @@ config MEMORY_HOTPLUG
>>  	bool "Allow for memory hot-add"
>>  	depends on SPARSEMEM || X86_64_ACPI_NUMA
>>  	depends on ARCH_ENABLE_MEMORY_HOTPLUG
>> +	depends on !KASAN
>>  
>>  config MEMORY_HOTPLUG_SPARSE
>>  	def_bool y
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
