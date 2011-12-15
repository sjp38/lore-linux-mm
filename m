Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 9E54A6B0170
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 03:55:48 -0500 (EST)
Received: by qan41 with SMTP id 41so140684qan.14
        for <linux-mm@kvack.org>; Thu, 15 Dec 2011 00:55:47 -0800 (PST)
Date: Thu, 15 Dec 2011 00:55:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4] oom: add trace points for debugging.
In-Reply-To: <20111213181225.673e19db.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1112150055010.10848@chino.kir.corp.google.com>
References: <20111213181225.673e19db.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 13 Dec 2011, KAMEZAWA Hiroyuki wrote:

> Subject: [PATCH] tracepoint: add tracepoints for debugging oom_score_adj.
> 
> oom_score_adj is used for guarding processes from OOM-Killer. One of problem
> is that it's inherited at fork(). When a daemon set oom_score_adj and
> make children, it's hard to know where the value is set.
> 
> This patch adds some tracepoints useful for debugging. This patch adds
> 3 trace points.
>   - creating new task
>   - renaming a task (exec)
>   - set oom_score_adj
> 
> To debug, users need to enable some trace pointer. Maybe filtering is useful as
> 
> # EVENT=/sys/kernel/debug/tracing/events/task/
> # echo "oom_score_adj != 0" > $EVENT/task_newtask/filter
> # echo "oom_score_adj != 0" > $EVENT/task_rename/filter
> # echo 1 > $EVENT/enable
> # EVENT=/sys/kernel/debug/tracing/events/oom/
> # echo 1 > $EVENT/enable
> 
> output will be like this.
> # grep oom /sys/kernel/debug/tracing/trace
> bash-7699  [007] d..3  5140.744510: oom_score_adj_update: pid=7699 comm=bash oom_score_adj=-1000
> bash-7699  [007] ...1  5151.818022: task_newtask: pid=7729 comm=bash clone_flags=1200011 oom_score_adj=-1000
> ls-7729  [003] ...2  5151.818504: task_rename: pid=7729 oldcomm=bash newcomm=ls oom_score_adj=-1000
> bash-7699  [002] ...1  5175.701468: task_newtask: pid=7730 comm=bash clone_flags=1200011 oom_score_adj=-1000
> grep-7730  [007] ...2  5175.701993: task_rename: pid=7730 oldcomm=bash newcomm=grep oom_score_adj=-1000
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for being persistant with this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
