Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DDB6E6B00B5
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 20:56:12 -0400 (EDT)
Message-ID: <4A70EF8D.9000004@redhat.com>
Date: Wed, 29 Jul 2009 20:55:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] tracing, page-allocator: Add trace events for page
 allocation and page freeing
References: <1248901551-7072-1-git-send-email-mel@csn.ul.ie> <1248901551-7072-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1248901551-7072-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> This patch adds trace events for the allocation and freeing of pages,
> including the freeing of pagevecs.  Using the events, it will be known what
> struct page and pfns are being allocated and freed and what the call site
> was in many cases.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
