Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E43B36B01AD
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 23:07:54 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5337q3B006827
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 12:07:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BEF2245DE50
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 12:07:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9481045DE4E
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 12:07:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 477991DB8015
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 12:07:51 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F2C0E1DB8012
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 12:07:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1006021421540.32666@chino.kir.corp.google.com>
References: <20100602222347.F527.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006021421540.32666@chino.kir.corp.google.com>
Message-Id: <20100603104314.723D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 12:07:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > The above story teach us oom-killer need some improvement. but it haven't
> > prove your patches are correct solution. that's why you got to ask testing way.
> 
> I would consider what I said above, "when faced with memory pressure from 
> an out of control or memory hogging task on the desktop, the oom killer 
> now kills it instead of a vital task such as an X server because of the 
> use of the task's rss instead of total_vm statistic" as an improvement 
> over killing X in those cases which it currently does.  How do you 
> disagree?

People observed simple s/total_vm/rss/ patch solve X issue. Then,
other additional pieces need to explain why that's necessary and
how to confirm it.

In other word, I'm sure I'll continue to get OOM bug report in future.
I'll need to decide revert or not revert each patches. no infomation is
unwelcome. also, that's the reason why all of rewrite patch is wrong.
if it will be merged, small bug report eventually is going to make
all of revert. that doesn't fit our developerment process.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
