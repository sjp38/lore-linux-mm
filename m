Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2948D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 20:30:12 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F141E3EE0B6
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:25:35 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA8C845DE55
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:25:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BEAA345DE54
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:25:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B2C591DB803A
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:25:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 407A4E38004
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 10:25:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH rh6] mm: skip zombie in OOM-killer
In-Reply-To: <1299274256-2122-1-git-send-email-avagin@openvz.org>
References: <1299274256-2122-1-git-send-email-avagin@openvz.org>
Message-Id: <20110308102508.7E99.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Mar 2011 10:25:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> A parent may wait a memory and zombie will prevent killing another task.
> 
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  mm/oom_kill.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7dcca55..2fc554e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -311,7 +311,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		 * blocked waiting for another task which itself is waiting
>  		 * for memory. Is there a better alternative?
>  		 */
> -		if (test_tsk_thread_flag(p, TIF_MEMDIE))
> +		if (test_tsk_thread_flag(p, TIF_MEMDIE) && p->mm)
>  			return ERR_PTR(-1UL);

OK. Good catch.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
