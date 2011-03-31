Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BF38A8D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 20:21:20 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E64DB3EE0C2
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:21:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC95245DE51
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:21:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B4C1445DE50
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:21:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A54AB1DB803F
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:21:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7103F1DB803B
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:21:16 +0900 (JST)
Date: Thu, 31 Mar 2011 09:14:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] x86,mm: make pagefault killable
Message-Id: <20110331091445.d2b969f4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110329194249.2B8E.A69D9226@jp.fujitsu.com>
References: <20110329193953.2B7E.A69D9226@jp.fujitsu.com>
	<20110329194249.2B8E.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 29 Mar 2011 19:42:10 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> When oom killer occured, almost processes are getting stuck following
> two points.
> 
> 	1) __alloc_pages_nodemask
> 	2) __lock_page_or_retry
> 
> 1) is not much problematic because TIF_MEMDIE lead to make allocation
> failure and get out from page allocator. 2) is more problematic. When
> OOM situation, Zones typically don't have page cache at all and Memory
> starvation might lead to reduce IO performance largely. When fork bomb
> occur, TIF_MEMDIE task don't die quickly mean fork bomb may create
> new process quickly rather than oom-killer kill it. Then, the system
> may become livelock.
> 
> This patch makes pagefault interruptible by SIGKILL.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
