Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 985BF6B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 05:56:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B95B93EE0B6
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:56:35 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B37F45DF57
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:56:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8340545DF54
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:56:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72CABE38003
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:56:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FCCEE08002
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:56:35 +0900 (JST)
Message-ID: <4DDE23C8.5000000@jp.fujitsu.com>
Date: Thu, 26 May 2011 18:56:24 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram
 internally
References: <1912242417.242053.1306402480853.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1912242417.242053.1306402480853.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: caiqian@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

>> @@ -160,7 +162,7 @@ unsigned int oom_badness(struct task_struct *p,
>> struct mem_cgroup *mem,
>> */
>> if (p->flags & PF_OOM_ORIGIN) {
>> task_unlock(p);
>> - return 1000;
>> + return ULONG_MAX;
>> }
> This part failed to apply to the latest git tree so unable to test those
> patches this time. Can you fix that?

Please apply ontop mmotm-0512.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
