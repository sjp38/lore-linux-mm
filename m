Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9236B6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:51:10 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id fb10so1798751wid.4
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 07:51:10 -0800 (PST)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id k6si6150174wja.131.2014.01.16.07.51.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 07:51:09 -0800 (PST)
Received: by mail-wi0-f170.google.com with SMTP id ex4so863955wid.3
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 07:51:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPp3RGpWhx4uoTTiSkUe9rZ2iJjMW6O2u=xdWL7BSskse=61qw@mail.gmail.com>
References: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
	<CAPp3RGpWhx4uoTTiSkUe9rZ2iJjMW6O2u=xdWL7BSskse=61qw@mail.gmail.com>
Date: Thu, 16 Jan 2014 09:51:09 -0600
Message-ID: <CAPp3RGonDThdAAr4c3FVowVHWhE02fHJTG5MH=QbJBNVfgx5Pg@mail.gmail.com>
Subject: Re: [PATCH] mm/nobootmem: Fix unused variable
From: Robin Holt <robinmholt@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Argh.  Thought I had changed that to plain text mode before sending.

Sorry for the noise,
Robin


On Thu, Jan 16, 2014 at 9:45 AM, Robin Holt <robinmholt@gmail.com> wrote:
>
> I can not see how this works.  How is the return from
> get_allocated_memblock_reserved_regions_info() stored and used without being
> declared?  Maybe you are working off a different repo than Linus' latest?  Your line
> 116 is my 114.  Maybe the message needs to be a bit more descriptive and
> certainly the bit after the '---' should be telling me what this is applying against.
>
> Robin
>
>
> On Thu, Jan 16, 2014 at 7:33 AM, Philipp Hachtmann <phacht@linux.vnet.ibm.com> wrote:
>>
>> This fixes an unused variable warning in nobootmem.c
>>
>> Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
>> ---
>>  mm/nobootmem.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
>> index e2906a5..12cbb04 100644
>> --- a/mm/nobootmem.c
>> +++ b/mm/nobootmem.c
>> @@ -116,9 +116,13 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
>>  static unsigned long __init free_low_memory_core_early(void)
>>  {
>>         unsigned long count = 0;
>> -       phys_addr_t start, end, size;
>> +       phys_addr_t start, end;
>>         u64 i;
>>
>> +#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
>> +       phys_addr_t size;
>> +#endif
>> +
>>         for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
>>                 count += __free_memory_core(start, end);
>>
>> --
>> 1.8.4.5
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
