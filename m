Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9DA6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 22:23:44 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 860D93EE0BD
	for <linux-mm@kvack.org>; Tue, 31 May 2011 11:23:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B7E145DECB
	for <linux-mm@kvack.org>; Tue, 31 May 2011 11:23:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EE6545DECE
	for <linux-mm@kvack.org>; Tue, 31 May 2011 11:23:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A39C1DB8049
	for <linux-mm@kvack.org>; Tue, 31 May 2011 11:23:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EAE691DB8044
	for <linux-mm@kvack.org>; Tue, 31 May 2011 11:23:40 +0900 (JST)
Message-ID: <4DE45119.9040108@jp.fujitsu.com>
Date: Tue, 31 May 2011 11:23:21 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, vmstat: Use cond_resched only when !CONFIG_PREEMPT
References: <1306774744.4061.5.camel@localhost.localdomain>
In-Reply-To: <1306774744.4061.5.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rakib.mullick@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 20c18b7..72cf857 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -461,7 +461,11 @@ void refresh_cpu_vm_stats(int cpu)
>  				p->expire = 3;
>  #endif
>  			}
> +
> +#ifndef CONFIG_PREEMPT
>  		cond_resched();
> +#endif
> +

In general, we should avoid #ifdef CONFIG_PREEMPT for maintainancebility as far as possible.
Is there any observable benefit? Can you please demonstrate it?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
