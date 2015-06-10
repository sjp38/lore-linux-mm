Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 905AB6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 23:08:10 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so27547919pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 20:08:10 -0700 (PDT)
Received: from mgwym04.jp.fujitsu.com (mgwym04.jp.fujitsu.com. [211.128.242.43])
        by mx.google.com with ESMTPS id b5si11544728pdn.44.2015.06.09.20.08.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 20:08:09 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id B409CAC036D
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 12:08:05 +0900 (JST)
Message-ID: <5577A9FF.4040603@jp.fujitsu.com>
Date: Wed, 10 Jun 2015 12:07:43 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 01/12] mm: add a new config to manage the code
References: <55704A7E.5030507@huawei.com> <55704B0C.1000308@huawei.com> <55768B42.80503@jp.fujitsu.com> <5576BBA5.20005@huawei.com>
In-Reply-To: <5576BBA5.20005@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/09 19:10, Xishi Qiu wrote:
> On 2015/6/9 14:44, Kamezawa Hiroyuki wrote:
>
>> On 2015/06/04 21:56, Xishi Qiu wrote:
>>> This patch introduces a new config called "CONFIG_ACPI_MIRROR_MEMORY", it is
>>> used to on/off the feature.
>>>
>>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>>> ---
>>>    mm/Kconfig | 8 ++++++++
>>>    1 file changed, 8 insertions(+)
>>>
>>> diff --git a/mm/Kconfig b/mm/Kconfig
>>> index 390214d..4f2a726 100644
>>> --- a/mm/Kconfig
>>> +++ b/mm/Kconfig
>>> @@ -200,6 +200,14 @@ config MEMORY_HOTREMOVE
>>>        depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>>>        depends on MIGRATION
>>>
>>> +config MEMORY_MIRROR
>>> +    bool "Address range mirroring support"
>>> +    depends on X86 && NUMA
>>> +    default y
>>> +    help
>>> +      This feature depends on hardware and firmware support.
>>> +      ACPI or EFI records the mirror info.
>>
>> default y...no runtime influence when the user doesn't use memory mirror ?
>>
>
> It is a new feature, so how about like this: default y -> n?
>

It's okay to me. But it's better to check performance impact before merge
because you modified core code of memory management.

Thanks,
-Kame
  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
