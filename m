Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 509EA6B01AD
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 20:10:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o530A91B025787
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Jun 2010 09:10:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 68F1745DE57
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:10:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 19C641EF081
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:10:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F34991DB8040
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:10:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BD3451DB803B
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 09:10:07 +0900 (JST)
Date: Thu, 3 Jun 2010 09:05:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
Message-Id: <20100603090552.1206dfb4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1006021421540.32666@chino.kir.corp.google.com>
References: <20100601074620.GR9453@laptop>
	<alpine.DEB.2.00.1006011144340.32024@chino.kir.corp.google.com>
	<20100602222347.F527.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006021421540.32666@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010 14:23:53 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 2 Jun 2010, KOSAKI Motohiro wrote:
> 
> > > I'm glad you asked that because some recent conversation has been 
> > > slightly confusing to me about how this affects the desktop; this rewrite 
> > > significantly improves the oom killer's response for desktop users.  The 
> > > core ideas were developed in the thread from this mailing list back in 
> > > February called "Improving OOM killer" at 
> > > http://marc.info/?t=126506191200004&r=4&w=2 -- users constantly report 
> > > that vital system tasks such as kdeinit are killed whenever a memory 
> > > hogging task is forked either intentionally or unintentionally.  I argued 
> > > for a while that KDE should be taking proper precautions by adjusting its 
> > > own oom_adj score and that of its forked children as it's an inherited 
> > > value, but I was eventually convinced that an overall improvement to the 
> > > heuristic must be made to kill a task that was known to free a large 
> > > amount of memory that is resident in RAM and that we have a consistent way 
> > > of defining oom priorities when a task is run uncontained and when it is a 
> > > member of a memcg or cpuset (or even mempolicy now), even in the case when 
> > > it's contained out from under the task's knowledge.  When faced with 
> > > memory pressure from an out of control or memory hogging task on the 
> > > desktop, the oom killer now kills it instead of a vital task such as an X 
> > > server (and oracle, webserver, etc on server platforms) because of the use 
> > > of the task's rss instead of total_vm statistic.
> > 
> > The above story teach us oom-killer need some improvement. but it haven't
> > prove your patches are correct solution. that's why you got to ask testing way.
> > 
> 
> I would consider what I said above, "when faced with memory pressure from 
> an out of control or memory hogging task on the desktop, the oom killer 
> now kills it instead of a vital task such as an X server because of the 
> use of the task's rss instead of total_vm statistic" as an improvement 
> over killing X in those cases which it currently does.  How do you 
> disagree?
> 

It was you who disagree using RSS for oom killing in the last winter.
By what observation did you change your mind ? (Don't take this as criticism.
I'm just curious.) 

My stand point:
I don't like the new interface at all but welcome the concept for using RSS .
And I and my custoemr will never use the new interface other than OOM_DISABLE.
So, I don't say ack nor nack.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
