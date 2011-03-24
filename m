Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E07B18D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 17:47:20 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p2OLlIoP002240
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:47:19 -0700
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by kpbe17.cbf.corp.google.com with ESMTP id p2OLkoxt029753
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:47:16 -0700
Received: by pwj4 with SMTP id 4so72725pwj.30
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:47:14 -0700 (PDT)
Date: Thu, 24 Mar 2011 14:47:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Accelerate OOM killing
In-Reply-To: <1300960353-2596-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <alpine.DEB.2.00.1103241446520.20718@chino.kir.corp.google.com>
References: <1300960353-2596-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>

On Thu, 24 Mar 2011, Minchan Kim wrote:

> When I test Andrey's problem, I saw the livelock and sysrq-t says
> there are many tasks in cond_resched after try_to_free_pages.
> 
> If did_some_progress is false, cond_resched could delay oom killing so
> It might be killing another task.
> 
> This patch accelerates oom killing without unnecessary giving CPU
> to another task. It could help avoding unnecessary another task killing
> and livelock situation a litte bit.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrey Vagin <avagin@openvz.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
