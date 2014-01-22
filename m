Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6049E6B0036
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 20:24:51 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so9156050pbc.2
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 17:24:51 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id ad3si7474177pad.293.2014.01.21.17.24.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 17:24:48 -0800 (PST)
Message-ID: <52DF1D59.8090803@huawei.com>
Date: Wed, 22 Jan 2014 09:22:33 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add a new command-line kmemcheck value
References: <52C2811C.4090907@huawei.com> <CAOMGZ=GOR_i9ixvHeHwfDN1wwwSQzFNFGa4qLZMhWWNzx0p8mw@mail.gmail.com> <52C4C216.3070607@huawei.com> <CAOMGZ=HhWoRYMQtqQu73X21eZJAO7fETxOnW=9ZWMkwr9dCPFA@mail.gmail.com>
In-Reply-To: <CAOMGZ=HhWoRYMQtqQu73X21eZJAO7fETxOnW=9ZWMkwr9dCPFA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vegard
 Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, wangnan0@huawei.com, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2014/1/11 0:02, Vegard Nossum wrote:

> On 2 January 2014 02:34, Xishi Qiu <qiuxishi@huawei.com> wrote:
>> On 2013/12/31 18:12, Vegard Nossum wrote:
>>> On 31 December 2013 09:32, Xishi Qiu <qiuxishi@huawei.com> wrote:
>>>> Add a new command-line kmemcheck value: kmemcheck=3 (disable the feature),
>>>> this is the same effect as CONFIG_KMEMCHECK disabled.
>>>> After doing this, we can enable/disable kmemcheck feature in one vmlinux.
>>>
>>> Could you please explain what exactly the difference is between the
>>> existing kmemcheck=0 parameter and the new kmemcheck=3?
>>
>> kmemcheck=0: enable kmemcheck feature, but don't check the memory.
>>         and the OS use only one cpu.(setup_max_cpus = 1)
>> kmemcheck=3: disable kmemcheck feature.
>>         this is the same effect as CONFIG_KMEMCHECK disabled.
>>         OS will use cpus as many as possible.
>>
> 
> I see. In that case, I think it's better to allow all the CPUs to keep
> running while kmemcheck is disabled with kmemcheck=0 boot parameter,
> and offline them when/if kmemcheck is reenabled via
> /proc/sys/kernel/kmemcheck.
> 
> 
> Vegard
> 
> 

Hi Vegard,

In some scenes, user want to check memory dynamicly, this "dynamically" 
means we can turn on/off the feature at boottime, not runtime. Without 
this patch, if user want to use this feature, he should change config 
and build the kernel, then reboot. This is impossilbe if user has no 
kernel code or he don't know how to build the kernel.

boottime: kmemcheck=0/1/2/3 (command-line)
runtime: kmemcheck=0/1/2 (/proc/sys/kernel/kmemcheck)

The main different between kmemcheck=0 and 3 is the used memory. Kmemcheck 
will use about twice as much memory as normal.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
