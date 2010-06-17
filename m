Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 024FC6B01D0
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 00:19:41 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o5H4Jb9Q018371
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:19:37 -0700
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by wpaz29.hot.corp.google.com with ESMTP id o5H4JW1j005258
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:19:34 -0700
Received: by pvg3 with SMTP id 3so801542pvg.6
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:19:32 -0700 (PDT)
Date: Wed, 16 Jun 2010 21:19:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/9] oom: oom_kill_process() need to check p is
 unkillable
In-Reply-To: <20100617104647.FB89.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006162118520.14101@chino.kir.corp.google.com>
References: <20100617104311.FB7A.A69D9226@jp.fujitsu.com> <20100617104647.FB89.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:

> When oom_kill_allocating_task is enabled, an argument task of
> oom_kill_process is not selected by select_bad_process(), It's
> just out_of_memory() caller task. It mean the task can be
> unkillable. check it first.
> 

This should be unnecessary if oom_kill_process() appropriately returns 
non-zero when it cannot kill a task.  What problem are you addressing with 
this fix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
