Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5DEFB8D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 09:08:45 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3542E3EE0B5
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 23:08:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1715545DE55
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 23:08:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3BAC45DE4D
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 23:08:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E09211DB802C
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 23:08:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AD5051DB8038
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 23:08:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
In-Reply-To: <20110309145457.0400.A69D9226@jp.fujitsu.com>
References: <4D767D43.5020802@gmail.com> <20110309145457.0400.A69D9226@jp.fujitsu.com>
Message-Id: <20110310224939.F926.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Mar 2011 23:08:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: avagin@gmail.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Hi, 
> 
> Hmmm...
> If I could observed your patch, I did support your opinion. but I didn't. so, now I'm 
> curious why we got the different conclusion. tommorow, I'll try to construct a test 
> environment to reproduce your system.

Hm, 

following two patches seems to have bad interaction. former makes
SCHED_FIFO when OOM, latter makes CPU 100% occupied busy loop if
LRU is really tight.
Of cource, I need to run more much test. I'll digg it more at this 
weekend (maybe).


commit 93b43fa55088fe977503a156d1097cc2055449a2
Author: Luis Claudio R. Goncalves <lclaudio@uudg.org>
Date:   Mon Aug 9 17:19:41 2010 -0700

    oom: give the dying task a higher priority


commit 0e093d99763eb4cea09f8ca4f1d01f34e121d10b
Author: Mel Gorman <mel@csn.ul.ie>
Date:   Tue Oct 26 14:21:45 2010 -0700

    writeback: do not sleep on the congestion queue if there are no congested BDIs or if significant conge



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
