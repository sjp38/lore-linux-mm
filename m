Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9156B0033
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 22:27:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so95002983pgd.7
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 19:27:46 -0800 (PST)
Received: from out0-144.mail.aliyun.com (out0-144.mail.aliyun.com. [140.205.0.144])
        by mx.google.com with ESMTP id b10si20525991pgf.141.2017.02.05.19.19.38
        for <linux-mm@kvack.org>;
        Sun, 05 Feb 2017 19:27:45 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <719282122.1183240.1486298780546.ref@mail.yahoo.com> <719282122.1183240.1486298780546@mail.yahoo.com>
In-Reply-To: <719282122.1183240.1486298780546@mail.yahoo.com>
Subject: Re: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
Date: Mon, 06 Feb 2017 11:19:24 +0800
Message-ID: <001001d28027$d13fb9a0$73bf2ce0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Shantanu Goel' <sgoel01@yahoo.com>, linux-mm@kvack.org

On February 05, 2017 8:46 PM Shantanu Goel wrote: 
> 
> Hi,
> 
Would you please reformat your patch and redeliver it after taking a look at 
files like 
	linux-4.9/Documentation/SubmitChecklist
	linux-4.9/Documentation/SubmittingPatches 

thanks
Hillf

> On 4.9.7 kswapd is failing to wake up kcompactd due to a mismatch in the zone balance check between balance_pgdat() and
> prepare_kswapd_sleep().  balance_pgdat() returns as soon as a single zone satisfies the allocation but prepare_kswapd_sleep()
> requires all zones to do the same.  This causes prepare_kswapd_sleep() to never succeed except in the order == 0 case and
> consequently, wakeup_kcompactd() is never called.  On my machine prior to apply this patch, the state of compaction from
> /proc/vmstat looked this way after a day and a half of uptime:
> 
> compact_migrate_scanned 240496
> compact_free_scanned 76238632
> compact_isolated 123472
> compact_stall 1791
> compact_fail 29
> compact_success 1762
> compact_daemon_wake 0
> 
> 
> After applying the patch and about 10 hours of uptime the state looks like this:
> 
> compact_migrate_scanned 59927299
> compact_free_scanned 2021075136
> compact_isolated 640926
> compact_stall 4
> compact_fail 2
> compact_success 2
> compact_daemon_wake 5160
> 
> 
> Thanks,
> Shantanu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
