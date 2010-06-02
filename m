Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A19A56B01B0
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:54:06 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o52Ds4XH016905
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Jun 2010 22:54:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B59C45DE51
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA39545DE4F
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C75C31DB803B
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A34C1DB803E
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1006011144340.32024@chino.kir.corp.google.com>
References: <20100601074620.GR9453@laptop> <alpine.DEB.2.00.1006011144340.32024@chino.kir.corp.google.com>
Message-Id: <20100602222347.F527.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed,  2 Jun 2010 22:54:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Such that you can look at your test case or workload and see that
> > it is really improved?
> > 
> 
> I'm glad you asked that because some recent conversation has been 
> slightly confusing to me about how this affects the desktop; this rewrite 
> significantly improves the oom killer's response for desktop users.  The 
> core ideas were developed in the thread from this mailing list back in 
> February called "Improving OOM killer" at 
> http://marc.info/?t=126506191200004&r=4&w=2 -- users constantly report 
> that vital system tasks such as kdeinit are killed whenever a memory 
> hogging task is forked either intentionally or unintentionally.  I argued 
> for a while that KDE should be taking proper precautions by adjusting its 
> own oom_adj score and that of its forked children as it's an inherited 
> value, but I was eventually convinced that an overall improvement to the 
> heuristic must be made to kill a task that was known to free a large 
> amount of memory that is resident in RAM and that we have a consistent way 
> of defining oom priorities when a task is run uncontained and when it is a 
> member of a memcg or cpuset (or even mempolicy now), even in the case when 
> it's contained out from under the task's knowledge.  When faced with 
> memory pressure from an out of control or memory hogging task on the 
> desktop, the oom killer now kills it instead of a vital task such as an X 
> server (and oracle, webserver, etc on server platforms) because of the use 
> of the task's rss instead of total_vm statistic.

The above story teach us oom-killer need some improvement. but it haven't
prove your patches are correct solution. that's why you got to ask testing way.

Nobody have objection to fix KDE OOM issue.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
