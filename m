Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 897BB6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 02:20:28 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so7186084pde.0
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 23:20:28 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id n8si17928383pax.334.2014.02.10.23.20.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 23:20:27 -0800 (PST)
Message-ID: <52F9CE72.30303@huawei.com>
Date: Tue, 11 Feb 2014 15:17:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add a new command-line kmemcheck value
References: <52C2811C.4090907@huawei.com> <CAOMGZ=GOR_i9ixvHeHwfDN1wwwSQzFNFGa4qLZMhWWNzx0p8mw@mail.gmail.com> <52C4C216.3070607@huawei.com> <CAOMGZ=HhWoRYMQtqQu73X21eZJAO7fETxOnW=9ZWMkwr9dCPFA@mail.gmail.com> <52DF1D59.8090803@huawei.com>
In-Reply-To: <52DF1D59.8090803@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vegard
 Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, wangnan0@huawei.com, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Xishi Qiu <qiuxishi@huawei.com>

On 2014/1/22 9:22, Xishi Qiu wrote:

> 
> Hi Vegard,
> 
> In some scenes, user want to check memory dynamicly, this "dynamically" 
> means we can turn on/off the feature at boottime, not runtime. Without 
> this patch, if user want to use this feature, he should change config 
> and build the kernel, then reboot. This is impossilbe if user has no 
> kernel code or he don't know how to build the kernel.
> 
> boottime: kmemcheck=0/1/2/3 (command-line)
> runtime: kmemcheck=0/1/2 (/proc/sys/kernel/kmemcheck)
> 
> The main different between kmemcheck=0 and 3 is the used memory. Kmemcheck 
> will use about twice as much memory as normal.
> 
> Thanks,
> Xishi Qiu
> 
> --

Hi Vegard,

What do you think of this feature? 

Add a command-line "kmemcheck=3", then the kernel runs as the same as CONFIG_KMEMCHECK=off
even CONFIG_KMEMCHECK is turn on. "kmemcheck=0/1/2" is the same as originally. 
In another word, "kmemcheck=3" is the same as:
1) turn off CONFIG_KMEMCHECK
2) rebuild the kernel
3) reboot
The different between kmemcheck=0 and 3 is the used memory and nr_cpus.
Also kmemcheck=0 can used in runtime, and kmemcheck=3 is only used in boot.

I think this feature can help users to debug the kernel quickly, It is no 
need to open CONFIG_KMEMCHECK and rebuild it. Especially sometimes users don't
have the kernel source code or the code is different from www.kernel.org.
e.g. some private features were added to the kernel source code, and usually 
users can not have the source code. 

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
