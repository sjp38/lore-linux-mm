Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D50F36B005A
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 09:46:09 -0400 (EDT)
Message-ID: <4A71A3FD.6030802@redhat.com>
Date: Thu, 30 Jul 2009 09:45:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing script
 for page-allocator-related ftrace events
References: <1248901551-7072-1-git-send-email-mel@csn.ul.ie> <1248901551-7072-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1248901551-7072-5-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
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

I like it.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
