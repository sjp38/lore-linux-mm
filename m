Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 08AAA6B0119
	for <linux-mm@kvack.org>; Sun,  5 Jun 2011 23:07:21 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 18F033EE0AE
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 12:07:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFEC945DED3
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 12:07:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2D5245DECD
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 12:07:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C0BEB1DB8040
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 12:07:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C2EF1DB803E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 12:07:17 +0900 (JST)
Message-ID: <4DEC4463.1060206@jp.fujitsu.com>
Date: Mon, 06 Jun 2011 12:07:15 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system have
 > gigabytes memory  (aka CAI founded issue)
References: <348391538.318712.1306828778575.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <4DE4A2A0.6090704@jp.fujitsu.com> <4DE4BC64.3040807@jp.fujitsu.com> <20110601033258.GA12653@barrios-laptop>
In-Reply-To: <20110601033258.GA12653@barrios-laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: caiqian@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

>> Of course, we recommend to drop privileges as far as possible
>> instead of keeping them. Thus, oom killer don't have to check
>> any capability. It implicitly suggest wrong programming style.
>>
>> This patch change root process check way from CAP_SYS_ADMIN to
>> just euid==0.
> 
> I like this but I have some comments.
> Firstly, it's not dependent with your series so I think this could
> be merged firstly.

I agree.

> Before that, I would like to make clear my concern.
> As I look below comment, 3% bonus is dependent with __vm_enough_memory's logic?

No. completely independent.

vm_enough_memory() check the task _can_ allocate more memory. IOW, the task
is subjective. And oom-killer check the task should be protected from oom-killer.
IOW, the task is objective.


> If it isn't, we can remove the comment. It would be another patch.
> If is is, could we change __vm_enough_memory for euid instead of cap?
> 
>         * Root processes get 3% bonus, just like the __vm_enough_memory()
> 	* implementation used by LSMs.

vm_enough_memory() is completely correct. I don't see any reason to change it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
