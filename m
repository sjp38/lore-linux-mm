Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3746D6B01F3
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 15:04:38 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o32J4WC6004260
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 12:04:32 -0700
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by wpaz37.hot.corp.google.com with ESMTP id o32J4VbL009075
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 12:04:31 -0700
Received: by pwi1 with SMTP id 1so1801396pwi.39
        for <linux-mm@kvack.org>; Fri, 02 Apr 2010 12:04:31 -0700 (PDT)
Date: Fri, 2 Apr 2010 12:04:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm 4/4] oom: oom_forkbomb_penalty: move thread_group_cputime()
 out of task_lock()
In-Reply-To: <20100402183309.GE31723@redhat.com>
Message-ID: <alpine.DEB.2.00.1004021203410.1773@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com>
 <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com> <20100402183057.GA31723@redhat.com>
 <20100402183309.GE31723@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Apr 2010, Oleg Nesterov wrote:

> It doesn't make sense to call thread_group_cputime() under task_lock(),
> we can drop this lock right after we read get_mm_rss() and save the
> value in the local variable.
> 
> Note: probably it makes more sense to use sum_exec_runtime instead
> of utime + stime, it is much more precise. A task can eat a lot of
> CPU time, but its Xtime can be zero.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
