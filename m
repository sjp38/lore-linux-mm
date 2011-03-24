Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 07F818D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 06:05:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DF6823EE0BC
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 19:05:38 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 59D6145DE68
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 19:05:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 40D5845DE55
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 19:05:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28C0DE08002
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 19:05:34 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DC9051DB802C
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 19:05:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Accelerate OOM killing
In-Reply-To: <1300960353-2596-1-git-send-email-minchan.kim@gmail.com>
References: <1300960353-2596-1-git-send-email-minchan.kim@gmail.com>
Message-Id: <20110324190534.5CC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 24 Mar 2011 19:05:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>

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

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
