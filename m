Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1486B01E8
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:20:50 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o517KkYK016738
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:20:46 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz24.hot.corp.google.com with ESMTP id o517Kid4027202
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:20:45 -0700
Received: by pzk36 with SMTP id 36so1186796pzk.32
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:20:44 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:20:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] oom: remove warning for in mm-less task
 __oom_kill_process()
In-Reply-To: <20100601144705.243D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006010020140.30615@chino.kir.corp.google.com>
References: <20100601144238.243A.A69D9226@jp.fujitsu.com> <20100601144705.243D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010, KOSAKI Motohiro wrote:

> If the race of mm detach in task exiting vs oom is happen,
> find_lock_task_mm() can be return NULL.
> 
> So, the warning is pointless. remove it.
> 

This is already removed with my patch 
oom-remove-unnecessary-code-and-cleanup.patch from my oom killer rewrite.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
