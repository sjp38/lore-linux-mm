Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E2AE66B01AF
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:20:46 -0400 (EDT)
Received: by pzk33 with SMTP id 33so31212pzk.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 07:20:41 -0700 (PDT)
Date: Wed, 30 Jun 2010 23:20:34 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 07/11] oom: move OOM_DISABLE check from oom_kill_task
 to out_of_memory()
Message-ID: <20100630142034.GF15644@barrios-desktop>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
 <20100630183059.AA5C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100630183059.AA5C.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 30, 2010 at 06:31:36PM +0900, KOSAKI Motohiro wrote:
> Now, if oom_kill_allocating_task is enabled and current have
> OOM_DISABLED, following printk in oom_kill_process is called twice.
> 
>     pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
>             message, task_pid_nr(p), p->comm, points);
> 
> So, OOM_DISABLE check should be more early.

If we check it in oom_unkillable_task, we don't need this patch. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
