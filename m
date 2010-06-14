Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 35DC96B01E4
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:55:53 -0400 (EDT)
Message-ID: <4C166D15.7050203@redhat.com>
Date: Mon, 14 Jun 2010 13:55:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/12] tracing, vmscan: Add a postprocessing script for
 reclaim-related ftrace events
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-5-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 06/14/2010 07:17 AM, Mel Gorman wrote:
> This patch adds a simple post-processing script for the reclaim-related
> trace events.  It can be used to give an indication of how much traffic
> there is on the LRU lists and how severe latencies due to reclaim are.
> Example output looks like the following

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
