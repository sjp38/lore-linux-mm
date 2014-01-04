Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id CC70A6B0031
	for <linux-mm@kvack.org>; Sat,  4 Jan 2014 16:37:11 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so7428438eaj.9
        for <linux-mm@kvack.org>; Sat, 04 Jan 2014 13:37:11 -0800 (PST)
Received: from smtp1.informatik.tu-muenchen.de (mail-out1.informatik.tu-muenchen.de. [131.159.0.8])
        by mx.google.com with ESMTPS id w6si77300609eeg.48.2014.01.04.13.37.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 13:37:10 -0800 (PST)
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	by mail.in.tum.de (Postfix) with ESMTPSA id 98DFC24043E
	for <linux-mm@kvack.org>; Sat,  4 Jan 2014 22:37:09 +0100 (CET)
Received: by mail-vc0-f177.google.com with SMTP id le5so463719vcb.36
        for <linux-mm@kvack.org>; Sat, 04 Jan 2014 13:37:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140104182235.GT20765@two.firstfloor.org>
References: <CAGz0_-2mkN=KCp=3WkPPVo2_JAtNJAkVpBcwfQ4LVr8R40P=tQ@mail.gmail.com>
	<20140104182235.GT20765@two.firstfloor.org>
Date: Sat, 4 Jan 2014 22:37:08 +0100
Message-ID: <CAGz0_-0Q0XxvmXZii0MUrgm8dmYYF5xck3398iyZA2dRySuw5w@mail.gmail.com>
Subject: Re: Is it possible to disable numa_balance after boot?
From: Andreas Hollmann <hollmann@in.tum.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-numa <linux-numa@vger.kernel.org>, linux-mm@kvack.org, mgorman@suse.de, akpm@linux-foundation.org

2014/1/4 Andi Kleen <andi@firstfloor.org>:
> On Sat, Jan 04, 2014 at 06:46:55PM +0100, Andreas Hollmann wrote:
>> Hi,
>>
>> is possible to turn of numa balancing (introduced in 3.8) in a running kernel?
>
>
> I submitted a patch to do it some time ago
>
> https://lkml.org/lkml/2013/4/24/529
>
> But it didn't seem to have made it in. Andrew? Mel?
>
> Yes I agree a disable switch is totally needed for such an intrusive
> feature, if only to isolate problems with it.

That would be great. Additionally it would be nice to do it per application.

Some applications work well with pinning, others don't and it would be
bad to disable numa balancing globally.

>
> -Andi
>
>
>>
>> I'm running a recent arch kernel and numa balancing is enabled by
>> default. I checked
>> several documents and found some sysctl variable which influence the behavior of
>> numa balance, but there is no clear documentation if it's possible to
>> disable it.
>>
>> The only defined way to disable it is using a kernel parameter
>>
>> numa_balancing= [KNL,X86] Enable or disable automatic NUMA balancing.
>> Allowed values are enable and disable
>>
>> Is there any other way?
>>
>> Best regards,
>> Andreas
>>
>>
>> $ uname -a
>> Linux inwest 3.12.6-1-ARCH #1 SMP PREEMPT Fri Dec 20 19:39:00 CET 2013
>> x86_64 GNU/Linux
>>
>> $ cat /usr/src/linux-3.12.6-1-ARCH/.config | grep NUMA_BALANCING
>> CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
>> CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
>> CONFIG_NUMA_BALANCING=y
>>
>> $ ls -l /proc/sys/kernel | grep numa_bal
>> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_delay_ms
>> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_period_max_ms
>> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_period_min_ms
>> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_period_reset
>> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_size_mb
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-numa" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> --
> ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
