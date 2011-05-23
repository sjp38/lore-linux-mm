Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 49F8E6B0012
	for <linux-mm@kvack.org>; Sun, 22 May 2011 22:37:01 -0400 (EDT)
Received: by qyk30 with SMTP id 30so3782852qyk.14
        for <linux-mm@kvack.org>; Sun, 22 May 2011 19:37:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DD62007.6020600@jp.fujitsu.com>
References: <4DD61F80.1020505@jp.fujitsu.com>
	<4DD62007.6020600@jp.fujitsu.com>
Date: Mon, 23 May 2011 11:37:00 +0900
Message-ID: <BANLkTineOmdV9wjK-5CmR9YTbMXyR8L7og@mail.gmail.com>
Subject: Re: [PATCH 2/5] oom: kill younger process first
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

2011/5/20 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> This patch introduces do_each_thread_reverse() and select_bad_process()
> uses it. The benefits are two, 1) oom-killer can kill younger process
> than older if they have a same oom score. Usually younger process is
> less important. 2) younger task often have PF_EXITING because shell
> script makes a lot of short lived processes. Reverse order search can
> detect it faster.
>
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
