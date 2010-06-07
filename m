Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5906B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 08:12:29 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o57CAfEP009308
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 06:10:41 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o57CCHJV169212
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 06:12:21 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o57CCGbP009022
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 06:12:17 -0600
Date: Mon, 7 Jun 2010 17:42:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch 01/18] oom: check PF_KTHREAD instead of !mm to skip
 kthreads
Message-ID: <20100607121204.GV4603@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1006061521160.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006061521160.32225@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2010-06-06 15:34:00]:

> From: Oleg Nesterov <oleg@redhat.com>
> 
> select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
> is not true due to use_mm().
> 
> Change the code to check PF_KTHREAD.
>

Quick check are all kernel threads marked with PF_KTHREAD? daemonize()
marks threads as kernel threads and I suppose children of init_task
inherit the flag on fork. I suppose both should cover all kernel
threads, but just checking to see if we missed anything.
 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
