Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA546B0038
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 02:34:24 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id p9so13965277lbv.0
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 23:34:23 -0800 (PST)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com. [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id d11si965912lbb.41.2015.02.12.23.34.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 23:34:22 -0800 (PST)
Received: by mail-lb0-f172.google.com with SMTP id p9so13129365lbv.3
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 23:34:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1918343840.1970155.1423788776414.JavaMail.yahoo@mail.yahoo.com>
References: <1918343840.1970155.1423788776414.JavaMail.yahoo@mail.yahoo.com>
Date: Fri, 13 Feb 2015 10:34:21 +0300
Message-ID: <CALYGNiP-CKYsVzLpUdUWM3ftfg1vPvKWQvbegXVLoNovtNWS6Q@mail.gmail.com>
Subject: Re: How to controll Buffers to be dilligently reclaimed?
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cheng Rk <crquan@ymail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Feb 13, 2015 at 3:52 AM, Cheng Rk <crquan@ymail.com> wrote:
>
>
> Hi,
>
> I have a system that application is doing a loop on top of block device,
> (which I think is stupid,)
> as more and more memory goes into Buffers, then applications started
> to get -ENOMEM or be oom-killed later (depends on vm.overcommit_memory setting)
>
>
> In this case, if I do a manual reclaim (echo 3 > /proc/sys/vm/drop_caches)
> I see 90+% of the Buffers is reclaimable, but why it's not reclaimed
> to fullfill applications' memory allocation request?
>
>
>
> -bash-4.2$ sudo losetup -a
> /dev/loop0: [0005]:16512 (/dev/dm-2)
> -bash-4.2$ free -m
>                      total          used         free      shared       buffers     cached
> Mem:             48094        46081         2012              40           40324   2085
> -/+ buffers/cache:             3671        44422
> Swap:             8191                5         8186
>
>
> I've tried sysctl mm.vfs_cache_pressure=10000 but that seems working to Cached
> memory, I wonder is there another sysctl for reclaming Buffers?

AFAIK "Buffers" is just a page-cache of block devices.
>From reclaimer's point of view they have no difference from file page-cache.

Could you post oom-killer log, there should be a lot of numbers
describing memory state.

>
>
> Thanks,
>
> - Derek
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
