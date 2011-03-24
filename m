Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBC78D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:34:07 -0400 (EDT)
Received: by pzk32 with SMTP id 32so7656pzk.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:11:05 -0700 (PDT)
Date: Fri, 25 Mar 2011 00:10:48 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 5/5] x86,mm: make pagefault killable
Message-ID: <20110324151048.GB1938@barrios-desktop>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
 <20110322194721.B05E.A69D9226@jp.fujitsu.com>
 <20110322200945.B06D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322200945.B06D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Mar 22, 2011 at 08:09:29PM +0900, KOSAKI Motohiro wrote:
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
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Looks like a cool idea.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
