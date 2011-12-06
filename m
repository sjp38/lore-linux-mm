Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 887916B0062
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 15:31:51 -0500 (EST)
Received: by iapp10 with SMTP id p10so10488437iap.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 12:31:50 -0800 (PST)
Date: Tue, 6 Dec 2011 12:31:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3.2-rc3] OOM killer doesn't kill the obvious memory hog
In-Reply-To: <20111202144441.4c2ff29e.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1112061231320.28251@chino.kir.corp.google.com>
References: <20111201093644.GW7046@dastard> <20111201185001.5bf85500.kamezawa.hiroyu@jp.fujitsu.com> <20111201124634.GY7046@dastard> <alpine.DEB.2.00.1112011432110.27778@chino.kir.corp.google.com> <20111202015921.GZ7046@dastard> <20111202033148.GA7046@dastard>
 <20111202144441.4c2ff29e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2 Dec 2011, KAMEZAWA Hiroyuki wrote:

> From ed565cbf842e0b30827fba7bfdbc724fe21d9d2d Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 2 Dec 2011 14:10:51 +0900
> Subject: [PATCH] oom_score_adj trace point.
> 
> oom_score_adj is set by some daemon and launch tasks ans inherited
> to applications, sometimes unexpectedly.
> 
> This patch is for debugging oom_score_adj inheritance. This
> adds trace points for oom_score_adj inheritance.
> 
>     bash-2501  [002]   448.860197: oom_score_adj_update: task 2501[bash] updates oom_score_adj=-1000
>     bash-2501  [002]   455.678190: oom_score_adj_inherited: new task 2527 inherited oom_score_adj -1000
>     ls-2527  [007]   455.678683: oom_score_task_rename: task 2527[bash] to [ls] oom_score_adj=-1000
>     bash-2501  [007]   461.632103: oom_score_adj_inherited: new task 2528 inherited oom_score_adj -1000
>     bash-2501  [007]   461.632335: oom_score_adj_inherited: new task 2529 inherited oom_score_adj -1000
>     ls-2528  [003]   461.632983: oom_score_task_rename: task 2528[bash] to [ls] oom_score_adj=-1000
>     less-2529  [005]   461.633086: oom_score_task_rename: task 2529[bash] to [less] oom_score_adj=-1000
>     bash-2501  [004]   474.888710: oom_score_adj_update: task 2501[bash] updates oom_score_adj=0
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks Kame!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
