Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DBF416B00BF
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 02:35:15 -0500 (EST)
Date: Wed, 23 Nov 2011 08:34:55 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: add task name to warn_scan_unevictable() messages
Message-ID: <20111123073455.GC11440@cmpxchg.org>
References: <1322027721-23677-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1322027721-23677-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

On Wed, Nov 23, 2011 at 12:55:20AM -0500, KOSAKI Motohiro wrote:
> If we need to know a usecase, caller program name is critical important.
> Show it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Oops, yes, this could be one hell to track down otherwise.  Thanks.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
