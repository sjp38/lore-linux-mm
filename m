Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 31A386B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 11:02:46 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z6so1401769yhz.15
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 08:02:45 -0800 (PST)
Received: from mail-oa0-x235.google.com (mail-oa0-x235.google.com [2607:f8b0:4003:c02::235])
        by mx.google.com with ESMTPS id t26si9529100yhl.280.2014.01.10.08.02.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 08:02:44 -0800 (PST)
Received: by mail-oa0-f53.google.com with SMTP id h16so5220148oag.40
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 08:02:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52C4C216.3070607@huawei.com>
References: <52C2811C.4090907@huawei.com>
	<CAOMGZ=GOR_i9ixvHeHwfDN1wwwSQzFNFGa4qLZMhWWNzx0p8mw@mail.gmail.com>
	<52C4C216.3070607@huawei.com>
Date: Fri, 10 Jan 2014 17:02:42 +0100
Message-ID: <CAOMGZ=HhWoRYMQtqQu73X21eZJAO7fETxOnW=9ZWMkwr9dCPFA@mail.gmail.com>
Subject: Re: [PATCH] mm: add a new command-line kmemcheck value
From: Vegard Nossum <vegard.nossum@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, wangnan0@huawei.com, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2 January 2014 02:34, Xishi Qiu <qiuxishi@huawei.com> wrote:
> On 2013/12/31 18:12, Vegard Nossum wrote:
>> On 31 December 2013 09:32, Xishi Qiu <qiuxishi@huawei.com> wrote:
>>> Add a new command-line kmemcheck value: kmemcheck=3 (disable the feature),
>>> this is the same effect as CONFIG_KMEMCHECK disabled.
>>> After doing this, we can enable/disable kmemcheck feature in one vmlinux.
>>
>> Could you please explain what exactly the difference is between the
>> existing kmemcheck=0 parameter and the new kmemcheck=3?
>
> kmemcheck=0: enable kmemcheck feature, but don't check the memory.
>         and the OS use only one cpu.(setup_max_cpus = 1)
> kmemcheck=3: disable kmemcheck feature.
>         this is the same effect as CONFIG_KMEMCHECK disabled.
>         OS will use cpus as many as possible.
>

I see. In that case, I think it's better to allow all the CPUs to keep
running while kmemcheck is disabled with kmemcheck=0 boot parameter,
and offline them when/if kmemcheck is reenabled via
/proc/sys/kernel/kmemcheck.


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
