Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D57C6B0023
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:17:09 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6B72C3EE0BC
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:17:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 44FC745DE5B
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:17:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D4B645DE59
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:17:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AC34EF8005
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:17:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D5844E08001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:17:05 +0900 (JST)
Message-ID: <4DCD0582.2020601@jp.fujitsu.com>
Date: Fri, 13 May 2011 19:18:42 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] oom: kill younger process first
References: <20110509182110.167F.A69D9226@jp.fujitsu.com>	<20110510171335.16A7.A69D9226@jp.fujitsu.com>	<20110510171641.16AF.A69D9226@jp.fujitsu.com> <20110512095243.c57e3e83.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110512095243.c57e3e83.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

(2011/05/12 9:52), KAMEZAWA Hiroyuki wrote:
> On Tue, 10 May 2011 17:15:01 +0900 (JST)
> KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>  wrote:
>
>> This patch introduces do_each_thread_reverse() and
>> select_bad_process() uses it. The benefits are two,
>> 1) oom-killer can kill younger process than older if
>> they have a same oom score. Usually younger process
>> is less important. 2) younger task often have PF_EXITING
>> because shell script makes a lot of short lived processes.
>> Reverse order search can detect it faster.
>>
>> Reported-by: CAI Qian<caiqian@redhat.com>
>> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>
> IIUC, for_each_thread() can be called under rcu_read_lock() but
> for_each_thread_reverse() must be under tasklist_lock.
>
> Could you add some comment ? and prev_task() should use list_entry()
> not list_entry_rcu().

Will fix. thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
