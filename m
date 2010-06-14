Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id ABE8D6B01D7
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:58:57 -0400 (EDT)
Subject: Re: [PATCH 04/12] tracing, vmscan: Add a postprocessing script for
	reclaim-related ftrace events
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <1276514273-27693-5-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	 <1276514273-27693-5-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 14 Jun 2010 17:03:44 -0400
Message-Id: <1276549425.8736.107.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 12:17 +0100, Mel Gorman wrote:
> This patch adds a simple post-processing script for the reclaim-related
> trace events.  It can be used to give an indication of how much traffic
> there is on the LRU lists and how severe latencies due to reclaim are.

Acked-by: Larry Woodman <lwoodman@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
