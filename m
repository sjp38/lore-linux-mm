Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 05D118D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 09:21:31 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 654CB3EE0B6
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 22:21:27 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B6B045DE6A
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 22:21:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 314FE45DE4E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 22:21:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 203B61DB8041
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 22:21:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D6AB51DB802C
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 22:21:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <20110401131214.GS2879@balbir.in.ibm.com>
References: <20110401165752.A889.A69D9226@jp.fujitsu.com> <20110401131214.GS2879@balbir.in.ibm.com>
Message-Id: <20110401222250.A894.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  1 Apr 2011 22:21:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2011-04-01 16:56:57]:
> 
> > Hi
> > 
> > > > 1) zone reclaim doesn't work if the system has multiple node and the
> > > >    workload is file cache oriented (eg file server, web server, mail server, et al). 
> > > >    because zone recliam make some much free pages than zone->pages_min and
> > > >    then new page cache request consume nearest node memory and then it
> > > >    bring next zone reclaim. Then, memory utilization is reduced and
> > > >    unnecessary LRU discard is increased dramatically.
> > > > 
> > > >    SGI folks added CPUSET specific solution in past. (cpuset.memory_spread_page)
> > > >    But global recliam still have its issue. zone recliam is HPC workload specific 
> > > >    feature and HPC folks has no motivation to don't use CPUSET.
> > > 
> > > I am afraid you misread the patches and the intent. The intent to
> > > explictly enable control of unmapped pages and has nothing
> > > specifically to do with multiple nodes at this point. The control is
> > > system wide and carefully enabled by the administrator.
> > 
> > Hm. OK, I may misread.
> > Can you please explain the reason why de-duplication feature need to selectable and
> > disabled by defaut. "explicity enable" mean this feature want to spot corner case issue??
> 
> Yes, because given a selection of choices (including what you
> mentioned in the review), it would be nice to have
> this selectable.

It's no good answer. :-/
Who need the feature and who shouldn't use it? It this enough valuable for enough large
people? That's my question point.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
