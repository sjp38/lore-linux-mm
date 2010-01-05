Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 488F36005A4
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 02:24:29 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o057OQtf002203
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 5 Jan 2010 16:24:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E4E2B45DE4F
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 16:24:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C76FE45DE4E
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 16:24:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AB7F21DB803A
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 16:24:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 58F19E08003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 16:24:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] page allocator: fix update NR_FREE_PAGES only as necessary
In-Reply-To: <4B41B653.2060204@gmail.com>
References: <20100104151444.96A8.A69D9226@jp.fujitsu.com> <4B41B653.2060204@gmail.com>
Message-Id: <20100105162354.459F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  5 Jan 2010 16:24:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >
> >> struct per_cpu_pageset {
> >>    .................................................
> >> #ifdef CONFIG_SMP
> >>       s8 stat_threshold;
> >>       s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
> >> #endif
> >> } ____cacheline_aligned_in_smp;
> >>
> >> The field 'stat_threshold' is in the CONFIG_SMP macro, does it not need
> >> the spinlock? I will read the code more carefully.
> >> I saw the macro, so I thought it need the spinlock. :)
> >>      
> > Generally,  per-cpu data isn't accessed from another cpu. it only need to care
> > process-context vs irq-context race.
> >    
> If the  __mod_zone_page_state() can be used without caring about the 
> spinlock, I think there
> are several places we can move __mod_zone_page_state() out the guard 
> area of spinlock to
> release the pressure of the zone->lock,such as in rmqueue_bulk().

Welcome to your patch :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
