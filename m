Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 913AD6B006C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 06:21:55 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so11894564pdj.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 03:21:55 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id pl10si8277427pbb.188.2015.06.09.03.21.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 03:21:54 -0700 (PDT)
Message-ID: <5576BBA5.20005@huawei.com>
Date: Tue, 9 Jun 2015 18:10:45 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 01/12] mm: add a new config to manage the code
References: <55704A7E.5030507@huawei.com> <55704B0C.1000308@huawei.com> <55768B42.80503@jp.fujitsu.com>
In-Reply-To: <55768B42.80503@jp.fujitsu.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/9 14:44, Kamezawa Hiroyuki wrote:

> On 2015/06/04 21:56, Xishi Qiu wrote:
>> This patch introduces a new config called "CONFIG_ACPI_MIRROR_MEMORY", it is
>> used to on/off the feature.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>   mm/Kconfig | 8 ++++++++
>>   1 file changed, 8 insertions(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 390214d..4f2a726 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -200,6 +200,14 @@ config MEMORY_HOTREMOVE
>>       depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>>       depends on MIGRATION
>>
>> +config MEMORY_MIRROR
>> +    bool "Address range mirroring support"
>> +    depends on X86 && NUMA
>> +    default y
>> +    help
>> +      This feature depends on hardware and firmware support.
>> +      ACPI or EFI records the mirror info.
> 
> default y...no runtime influence when the user doesn't use memory mirror ?
> 

It is a new feature, so how about like this: default y -> n?

Thanks,
Xishi Qiu

> Thanks,
> -Kame
> 
> 
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
