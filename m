Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id D649E6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 23:00:01 -0400 (EDT)
Received: by oiax193 with SMTP id x193so131993427oia.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 20:00:01 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id m2si30553388oey.25.2015.06.29.19.59.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 20:00:01 -0700 (PDT)
Message-ID: <55920450.703@huawei.com>
Date: Tue, 30 Jun 2015 10:52:00 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 1/8] mm: add a new config to manage the code
References: <558E084A.60900@huawei.com> <558E0913.7020501@huawei.com> <5590EAA9.5090104@jp.fujitsu.com>
In-Reply-To: <5590EAA9.5090104@jp.fujitsu.com>
Content-Type: text/plain; charset="Shift_JIS"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/29 14:50, Kamezawa Hiroyuki wrote:

> On 2015/06/27 11:23, Xishi Qiu wrote:
>> This patch introduces a new config called "CONFIG_ACPI_MIRROR_MEMORY", set it
>                                              CONFIG_MEMORY_MIRROR
>> off by default.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>   mm/Kconfig | 8 ++++++++
>>   1 file changed, 8 insertions(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 390214d..c40bb8b 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -200,6 +200,14 @@ config MEMORY_HOTREMOVE
>>       depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>>       depends on MIGRATION
>>
>> +config MEMORY_MIRROR
> 
>   In following patches, you use CONFIG_MEMORY_MIRROR.
> 
> I think the name is too generic besides it's depends on ACPI.
> But I'm not sure address based memory mirror is planned in other platform.
> 
> So, hmm. How about dividing the config into 2 parts like attached ? (just an example)
> 

Seems like a good idea, thank you.

> Thanks,
> -Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
