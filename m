Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 742466B00BC
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 21:40:22 -0400 (EDT)
Message-ID: <4A70F9E9.5000007@redhat.com>
Date: Wed, 29 Jul 2009 21:39:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] tracing, mm: Add trace events for anti-fragmentation
 falling back to other migratetypes
References: <1248901551-7072-1-git-send-email-mel@csn.ul.ie> <1248901551-7072-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1248901551-7072-3-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> Fragmentation avoidance depends on being able to use free pages from
> lists of the appropriate migrate type. In the event this is not
> possible, __rmqueue_fallback() selects a different list and in some
> circumstances change the migratetype of the pageblock. Simplistically,
> the more times this event occurs, the more likely that fragmentation
> will be a problem later for hugepage allocation at least but there are
> other considerations such as the order of page being split to satisfy
> the allocation.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
