Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD2E6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:40:30 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so16196169pdj.2
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 04:40:30 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id s4si18230764pbg.3.2014.02.18.04.40.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 04:40:28 -0800 (PST)
Message-ID: <53035433.3000405@huawei.com>
Date: Tue, 18 Feb 2014 20:38:11 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] mm: add a new command-line kmemcheck value
References: <53017544.90908@huawei.com> <CAOMGZ=Ht22+KuYwmGcJB4gkiu3EpFfj1EFoAF7Mtd7WvjXwJ3A@mail.gmail.com>
In-Reply-To: <CAOMGZ=Ht22+KuYwmGcJB4gkiu3EpFfj1EFoAF7Mtd7WvjXwJ3A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vegard
 Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>

On 2014/2/18 18:28, Vegard Nossum wrote:

> On 17 February 2014 03:34, Xishi Qiu <qiuxishi@huawei.com> wrote:
>> If we want to debug the kernel memory, we should turn on CONFIG_KMEMCHECK
>> and rebuild the kernel. This always takes a long time and sometimes
>> impossible, e.g. users don't have the kernel source code or the code
>> is different from "www.kernel.org" (private features may be added to the
>> kernel, and usually users can not get the whole code).
>>
>> This patch adds a new command-line "kmemcheck=3", then the kernel will run
>> as the same as CONFIG_KMEMCHECK=off even CONFIG_KMEMCHECK is turn on.
>> "kmemcheck=0/1/2" is the same as originally. This means we can always turn
>> on CONFIG_KMEMCHECK, and use "kmemcheck=3" to control it on/off with out
>> rebuild the kernel.
>>
>> In another word, "kmemcheck=3" is equivalent:
>> 1) turn off CONFIG_KMEMCHECK
>> 2) rebuild the kernel
>> 3) reboot
>>
>> The different between kmemcheck=0 and 3 is the used memory and nr_cpus.
>> Also kmemcheck=0 can used in runtime, and kmemcheck=3 is only used in boot.
>> boottime: kmemcheck=0/1/2/3 (command-line)
>> runtime: kmemcheck=0/1/2 (/proc/sys/kernel/kmemcheck)
> 
> This is not the right way to do what you want.
> 
> The behaviour that we want is:
> 
>  - CONFIG_KMEMCHECK=y + kmemcheck=0 (boot parameter) should have a
> minimal runtime impact and not limit the number of CPUs
>  - CONFIG_KMEMCHECK=y + kmemcheck=1 should limit the number of CPUs during boot
>  - setting kmemcheck to 1 via /proc/sys/kernel/kmemcheck should
> probably return an error if more than 1 CPU is online
> 
> 
> Vegard
> 

Hi Vegard,

Thank you for your reply. If we only use "kmemcheck=0" to control, how about
the used memory? Will it use about twice as much memory as normal?

Thanks,
Xishi Qiu

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
