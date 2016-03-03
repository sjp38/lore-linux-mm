Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7E36B0253
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 21:18:59 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id l127so12861360iof.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 18:18:59 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id c21si1151172ioe.188.2016.03.02.18.17.45
        for <linux-mm@kvack.org>;
        Wed, 02 Mar 2016 18:18:58 -0800 (PST)
Message-ID: <56D79E35.7030000@cn.fujitsu.com>
Date: Thu, 3 Mar 2016 10:15:17 +0800
From: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v5 0/5] Make cpuid <-> nodeid mapping persistent
References: <1456969327-20011-1-git-send-email-zhugh.fnst@cn.fujitsu.com> <CAJZ5v0j1WMi5qMYoUeto8EbV2XnhZQ1j7eQ3jJtoC7h5dOxxkw@mail.gmail.com>
In-Reply-To: <CAJZ5v0j1WMi5qMYoUeto8EbV2XnhZQ1j7eQ3jJtoC7h5dOxxkw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: cl@linux.com, Tejun Heo <tj@kernel.org>, mika.j.penttila@gmail.com, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "H. Peter Anvin" <hpa@zytor.com>, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, Len Brown <len.brown@intel.com>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, chen.tang@easystack.cn, x86@kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi,

On 03/03/2016 10:08 AM, Rafael J. Wysocki wrote:
> Hi,
>
> On Thu, Mar 3, 2016 at 2:42 AM, Zhu Guihua <zhugh.fnst@cn.fujitsu.com> wrote:
>> [Problem]
>>
>> cpuid <-> nodeid mapping is firstly established at boot time. And workqueue caches
>> the mapping in wq_numa_possible_cpumask in wq_numa_init() at boot time.
>>
>> When doing node online/offline, cpuid <-> nodeid mapping is established/destroyed,
>> which means, cpuid <-> nodeid mapping will change if node hotplug happens. But
>> workqueue does not update wq_numa_possible_cpumask.
>>
> Are there any changes in this version relative to the previous one?
No, there are no changes in this version.

Thanks,
Zhu

>
> Thanks,
> Rafael
>
>
> .
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
