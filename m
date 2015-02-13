Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id E3F176B0038
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 04:56:07 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id h15so9530589igd.4
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 01:56:07 -0800 (PST)
Received: from nm39-vm5.bullet.mail.ne1.yahoo.com (nm39-vm5.bullet.mail.ne1.yahoo.com. [98.138.229.165])
        by mx.google.com with ESMTPS id o66si5055906ioe.84.2015.02.13.01.56.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 01:56:07 -0800 (PST)
Date: Fri, 13 Feb 2015 09:52:16 +0000 (UTC)
From: Cheng Rk <crquan@ymail.com>
Reply-To: Cheng Rk <crquan@ymail.com>
Message-ID: <131740628.109294.1423821136530.JavaMail.yahoo@mail.yahoo.com>
In-Reply-To: <CALYGNiP-CKYsVzLpUdUWM3ftfg1vPvKWQvbegXVLoNovtNWS6Q@mail.gmail.com>
References: <CALYGNiP-CKYsVzLpUdUWM3ftfg1vPvKWQvbegXVLoNovtNWS6Q@mail.gmail.com>
Subject: Re: How to controll Buffers to be dilligently reclaimed?
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>



On Thursday, February 12, 2015 11:34 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:

>>
>> -bash-4.2$ sudo losetup -a
>> /dev/loop0: [0005]:16512 (/dev/dm-2)
>> -bash-4.2$ free -m
>>                 total          used         free      shared       buffers     cached
>> Mem:             48094         46081         2012          40         40324       2085
>> -/+ buffers/cache:              3671       44422
>> Swap:             8191             5         8186
>>
>>
>> I've tried sysctl mm.vfs_cache_pressure=10000 but that seems working to Cached
>> memory, I wonder is there another sysctl for reclaming Buffers?

> AFAIK "Buffers" is just a page-cache of block devices.
> From reclaimer's point of view they have no difference from file page-cache.

> Could you post oom-killer log, there should be a lot of numbers
> describing memory state.


in this case, 40GB memory got stuck in Buffers, and 90+% of them are reclaimable (can be verified by vm.drop_caches manual reclaim)
if Buffers are treated same as Cached, why mm.vfs_cache_pressure=10000 (or even I tried up to 1,000,000) can't get Buffers reclaimed early?


I have some oom-killer msgs but were with older kernels, after set vm.overcommit_memory=2, it simply returns -ENOMEM, unable to spawn any new container, why doesn't it even try to reclaim some memory from those 40GB Buffers,



Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
