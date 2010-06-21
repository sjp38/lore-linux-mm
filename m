Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 401FD6B01B8
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:15:20 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o5LKFGdA017671
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:15:16 -0700
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by wpaz5.hot.corp.google.com with ESMTP id o5LKFFTZ015345
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:15:15 -0700
Received: by pxi1 with SMTP id 1so423973pxi.9
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:15:15 -0700 (PDT)
Date: Mon, 21 Jun 2010 13:15:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/9] oom: make oom_unkillable_task() helper function
In-Reply-To: <20100617104637.FB86.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006211314370.8367@chino.kir.corp.google.com>
References: <20100617104311.FB7A.A69D9226@jp.fujitsu.com> <20100617104637.FB86.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:

> 
> Now, we have the same task check in two places. Unify it.
> 

We should exclude tasks from select_bad_process() and oom_kill_process() 
by having badness() return a score of 0, just like it's done for 
OOM_DISABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
