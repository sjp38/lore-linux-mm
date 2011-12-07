Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 615A46B005C
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 20:22:16 -0500 (EST)
Received: by ghbg19 with SMTP id g19so39840ghb.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 17:22:15 -0800 (PST)
Date: Tue, 6 Dec 2011 17:22:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: add tracepoints for oom_score_adj
In-Reply-To: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1112061721230.25238@chino.kir.corp.google.com>
References: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, dchinner@redhat.com

On Wed, 7 Dec 2011, KAMEZAWA Hiroyuki wrote:

> From 28189e4622fd97324893a0b234183f64472a54d6 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 7 Dec 2011 09:58:16 +0900
> Subject: [PATCH] oom: trace point for oom_score_adj
> 
> oom_score_adj is set to prevent a task from being killed by OOM-Killer.
> Some daemons sets this value and their children inerit it sometimes.
> Because inheritance of oom_score_adj is done automatically, users
> can be confused at seeing the value and finds it's hard to debug.
> 
> This patch adds trace point for oom_score_adj. This adds 3 trace
> points. at
> 	- update oom_score_adj
> 	- fork()
> 	- rename task->comm(typically, exec())
> 
> Outputs will be following.
>    bash-2404  [006]   199.620841: oom_score_adj_update: task 2404[bash] updates oom_score_ad  j=-1000
>    bash-2404  [006]   205.861287: oom_score_adj_inherited: new_task=2442 oom_score_adj=-1000
>    su-2442  [003]   205.861761: oom_score_task_rename: rename task 2442[bash] to [su] oom_  score_adj=-1000
>    su-2442  [003]   205.866737: oom_score_adj_inherited: new_task=2444 oom_score_adj=-1000
>    bash-2444  [007]   205.868136: oom_score_task_rename: rename task 2444[su] to [bash] oom_  score_adj=-1000
>    bash-2444  [007]   205.870407: oom_score_adj_inherited: new_task=2445 oom_score_adj=-1000
>    bash-2445  [001]   205.870975: oom_score_adj_inherited: new_task=2446 oom_score_adj=-1000
> 

Little bit of whitespace damage there, but looks good in the code itself.

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Just minor alterations to the format of the tracepoints from the first 
version, so carry over my

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
