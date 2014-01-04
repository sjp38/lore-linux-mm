Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6A96B0031
	for <linux-mm@kvack.org>; Sat,  4 Jan 2014 13:22:37 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so7379667eaj.9
        for <linux-mm@kvack.org>; Sat, 04 Jan 2014 10:22:36 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id l2si76630778een.125.2014.01.04.10.22.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 10:22:36 -0800 (PST)
Date: Sat, 4 Jan 2014 19:22:35 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Is it possible to disable numa_balance after boot?
Message-ID: <20140104182235.GT20765@two.firstfloor.org>
References: <CAGz0_-2mkN=KCp=3WkPPVo2_JAtNJAkVpBcwfQ4LVr8R40P=tQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGz0_-2mkN=KCp=3WkPPVo2_JAtNJAkVpBcwfQ4LVr8R40P=tQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Hollmann <hollmann@in.tum.de>
Cc: linux-numa <linux-numa@vger.kernel.org>, linux-mm@kvack.org, mgorman@suse.de, akpm@linux-foundation.org

On Sat, Jan 04, 2014 at 06:46:55PM +0100, Andreas Hollmann wrote:
> Hi,
> 
> is possible to turn of numa balancing (introduced in 3.8) in a running kernel?


I submitted a patch to do it some time ago

https://lkml.org/lkml/2013/4/24/529

But it didn't seem to have made it in. Andrew? Mel?

Yes I agree a disable switch is totally needed for such an intrusive
feature, if only to isolate problems with it.

-Andi


> 
> I'm running a recent arch kernel and numa balancing is enabled by
> default. I checked
> several documents and found some sysctl variable which influence the behavior of
> numa balance, but there is no clear documentation if it's possible to
> disable it.
> 
> The only defined way to disable it is using a kernel parameter
> 
> numa_balancing= [KNL,X86] Enable or disable automatic NUMA balancing.
> Allowed values are enable and disable
> 
> Is there any other way?
> 
> Best regards,
> Andreas
> 
> 
> $ uname -a
> Linux inwest 3.12.6-1-ARCH #1 SMP PREEMPT Fri Dec 20 19:39:00 CET 2013
> x86_64 GNU/Linux
> 
> $ cat /usr/src/linux-3.12.6-1-ARCH/.config | grep NUMA_BALANCING
> CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
> CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
> CONFIG_NUMA_BALANCING=y
> 
> $ ls -l /proc/sys/kernel | grep numa_bal
> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_delay_ms
> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_period_max_ms
> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_period_min_ms
> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_period_reset
> -rw-r--r-- 1 root root 0 Jan  4 14:23 numa_balancing_scan_size_mb
> --
> To unsubscribe from this list: send the line "unsubscribe linux-numa" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
