Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EFC5E8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 22:06:45 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E9C9D3EE0BB
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:06:42 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D105645DE4E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:06:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BA44C45DE4D
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:06:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AC1511DB8037
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:06:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 79ACD1DB802F
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:06:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
In-Reply-To: <20110308094438.1ba05ed2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110307135831.9e0d7eaa.akpm@linux-foundation.org> <20110308094438.1ba05ed2.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20110308120615.7EB9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Mar 2011 12:06:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrew Vagin <avagin@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> > > Hmm.. Although it solves the problem, I think it's not a good idea that
> > > depends on false alram and give up the retry.
> > 
> > Any alternative proposals?  We should get the livelock fixed if possible..
> 
> I agree with Minchan and can't think this is a real fix....
> Andrey, I'm now trying your fix and it seems your fix for oom-killer,
> 'skip-zombie-process' works enough good for my environ.
> 
> What is your enviroment ? number of cpus ? architecture ? size of memory ?

me too. 'skip-zombie-process V1' work fine. and I didn't seen this patch
improve oom situation.

And, The test program is purely fork bomb. Our oom-killer is not silver
bullet for fork bomb from very long time ago. That said, oom-killer send 
SIGKILL and start to kill the victim process. But, it doesn't prevent 
to be created new memory hogging tasks. Therefore we have no gurantee 
to win process exiting and creating race.

*IF* we really need to care fork bomb issue, we need to write completely 
new VM feature.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
