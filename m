Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BD2196B01AD
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:50:22 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o57JoH5q004810
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 12:50:18 -0700
Received: from pzk38 (pzk38.prod.google.com [10.243.19.166])
	by wpaz37.hot.corp.google.com with ESMTP id o57JoGKn013429
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 12:50:16 -0700
Received: by pzk38 with SMTP id 38so30807pzk.28
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 12:50:16 -0700 (PDT)
Date: Mon, 7 Jun 2010 12:50:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 01/18] oom: check PF_KTHREAD instead of !mm to skip
 kthreads
In-Reply-To: <20100607121204.GV4603@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1006071249310.30389@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061521160.32225@chino.kir.corp.google.com> <20100607121204.GV4603@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jun 2010, Balbir Singh wrote:

> > select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
> > is not true due to use_mm().
> > 
> > Change the code to check PF_KTHREAD.
> >
> 
> Quick check are all kernel threads marked with PF_KTHREAD? daemonize()
> marks threads as kernel threads and I suppose children of init_task
> inherit the flag on fork. I suppose both should cover all kernel
> threads, but just checking to see if we missed anything.
>  

Right, it's the inheritance from init_task that is the key which gets 
cleared on exec for all user threads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
