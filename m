Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2BF3E600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 01:13:11 -0500 (EST)
Received: by ywh5 with SMTP id 5so28197140ywh.11
        for <linux-mm@kvack.org>; Sun, 03 Jan 2010 22:13:00 -0800 (PST)
Message-ID: <4B4186A7.5080402@gmail.com>
Date: Mon, 04 Jan 2010 14:11:51 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] page allocator: fix update NR_FREE_PAGES only as necessary
References: <1262571730-2778-1-git-send-email-shijie8@gmail.com> <20100104122138.f54b7659.minchan.kim@barrios-desktop> <20100104144332.96A2.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100104144332.96A2.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> Why can't we write following? __mod_zone_page_state() only require irq
> disabling, it doesn't need spin lock. I think.
>
>
>
struct per_cpu_pageset {
  .................................................
#ifdef CONFIG_SMP
     s8 stat_threshold;
     s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
#endif
} ____cacheline_aligned_in_smp;

The field 'stat_threshold' is in the CONFIG_SMP macro, does it not need 
the spinlock? I will read the code more carefully.
I saw the macro, so I thought it need the spinlock. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
