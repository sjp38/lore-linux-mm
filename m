Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id F244B6B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 21:49:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5EB563EE0C1
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 10:49:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BD2A45DE58
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 10:49:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1338A45DE5A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 10:49:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F0845E0800A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 10:49:13 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A4B0BE08008
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 10:49:13 +0900 (JST)
Message-ID: <51E74974.9050605@jp.fujitsu.com>
Date: Thu, 18 Jul 2013 10:48:36 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
References: <1374097503-25515-1-git-send-email-toshi.kani@hp.com>  <CAHGf_=pND-R=qMHg7b=Fi5SqS6ahXJCG865WsOS2eKWa6g3A7A@mail.gmail.com>  <1374103783.24916.49.camel@misato.fc.hp.com>  <CAHGf_=q-9C4JZgv9Xp1Z3_Ks1a7t_sOArD3e1myj1EdiH5GBHQ@mail.gmail.com> <1374105078.24916.62.camel@misato.fc.hp.com>
In-Reply-To: <1374105078.24916.62.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, "vasilis.liaskovitis" <vasilis.liaskovitis@profitbricks.com>

(2013/07/18 8:51), Toshi Kani wrote:
> On Wed, 2013-07-17 at 19:33 -0400, KOSAKI Motohiro wrote:
>> On Wed, Jul 17, 2013 at 7:29 PM, Toshi Kani <toshi.kani@hp.com> wrote:
>>> On Wed, 2013-07-17 at 19:22 -0400, KOSAKI Motohiro wrote:
>>>> On Wed, Jul 17, 2013 at 5:45 PM, Toshi Kani <toshi.kani@hp.com> wrote:
>>>>> CONFIG_ARCH_MEMORY_PROBE enables /sys/devices/system/memory/probe
>>>>> interface, which allows a given memory address to be hot-added as
>>>>> follows. (See Documentation/memory-hotplug.txt for more detail.)
>>>>>
>>>>> # echo start_address_of_new_memory > /sys/devices/system/memory/probe
>>>>>
>>>>> This probe interface is required on powerpc. On x86, however, ACPI
>>>>> notifies a memory hotplug event to the kernel, which performs its
>>>>> hotplug operation as the result. Therefore, users should not be
>>>>> required to use this interface on x86. This probe interface is also
>>>>> error-prone that the kernel blindly adds a given memory address
>>>>> without checking if the memory is present on the system; no probing
>>>>> is done despite of its name. The kernel crashes when a user requests
>>>>> to online a memory block that is not present on the system.
>>>>>
>>>>> This patch disables CONFIG_ARCH_MEMORY_PROBE by default on x86,
>>>>> and clarifies it in Documentation/memory-hotplug.txt.
>>>>
>>>> Why don't you completely remove it? Who should use this strange interface?
>>>
>>> According to the comment below, this probe interface is used on powerpc.
>>> So, we cannot remove it, but to disable it on x86.
>>
>> I meant x86. Why can't we completely remove ARCH_MEMORY_PROBE section
>> from x86 Kconfig?
>
> Oh, I see what you meant.  I do not expect any need for end-users, but I
> was not sure if someone working on the memory hotplug development might
> use it for fake hot-add testing.  Yes, if you folks do not see any need,
> I will remove it from x86 Kconfig.

I do not think the interface is necessary. So I vote to Kosaki's opinion.

Thanks,
Yasuaki Ishimatsu

>
> Thanks,
> -Toshi
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
