Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 039BB6B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 13:54:07 -0400 (EDT)
Date: Tue, 4 Aug 2009 11:22:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
 script for page-allocator-related ftrace events
Message-Id: <20090804112246.4e6d0ab1.akpm@linux-foundation.org>
In-Reply-To: <1249409546-6343-5-git-send-email-mel@csn.ul.ie>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>
	<1249409546-6343-5-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  4 Aug 2009 19:12:26 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> This patch adds a simple post-processing script for the page-allocator-related
> trace events. It can be used to give an indication of who the most
> allocator-intensive processes are and how often the zone lock was taken
> during the tracing period. Example output looks like
> 
> find-2840
>  o pages allocd            = 1877
>  o pages allocd under lock = 1817
>  o pages freed directly    = 9
>  o pcpu refills            = 1078
>  o migrate fallbacks       = 48
>    - fragmentation causing = 48
>      - severe              = 46
>      - moderate            = 2
>    - changed migratetype   = 7

The usual way of accumulating and presenting such measurements is via
/proc/vmstat.  How do we justify adding a completely new and different
way of doing something which we already do?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
