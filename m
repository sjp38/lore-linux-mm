Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8E86F6006F7
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:05:17 -0400 (EDT)
Received: by pxi17 with SMTP id 17so420488pxi.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 07:05:16 -0700 (PDT)
Date: Wed, 30 Jun 2010 22:57:31 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 04/11] oom: oom_kill_process() need to check p is
 unkillable
Message-ID: <20100630135731.GB15644@barrios-desktop>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
 <20100630182838.AA53.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100630182838.AA53.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 30, 2010 at 06:29:22PM +0900, KOSAKI Motohiro wrote:
> When oom_kill_allocating_task is enabled, an argument task of
> oom_kill_process is not selected by select_bad_process(), It's
> just out_of_memory() caller task. It mean the task can be
> unkillable. check it first.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
