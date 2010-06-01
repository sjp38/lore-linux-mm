Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AF7076B01CD
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:44:50 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o51KimEE008239
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:44:48 -0700
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by hpaq3.eem.corp.google.com with ESMTP id o51Kijmn025716
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:44:46 -0700
Received: by pxi3 with SMTP id 3so1929635pxi.10
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 13:44:45 -0700 (PDT)
Date: Tue, 1 Jun 2010 13:44:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/5] oom: __oom_kill_task() must use find_lock_task_mm()
 too
In-Reply-To: <20100531183727.184F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006011344120.13136@chino.kir.corp.google.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com> <20100531183727.184F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 31 May 2010, KOSAKI Motohiro wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Subject: [PATCH 5/5] oom: __oom_kill_task() must use find_lock_task_mm() too
> 
> __oom_kill_task also use find_lock_task_mm(). because if sysctl_oom_kill_allocating_task
> is true, __out_of_memory() don't call select_bad_process().
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

This code is removed as part of my oom killer rewrite as patch 12/18 "oom: 
remove unnecessary code and cleanup".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
