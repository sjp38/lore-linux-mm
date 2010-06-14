Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6B6B16B01D1
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:57:34 -0400 (EDT)
Subject: Re: [PATCH 02/12] tracing, vmscan: Add trace events for LRU page
	isolation
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <1276514273-27693-3-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	 <1276514273-27693-3-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 14 Jun 2010 17:02:10 -0400
Message-Id: <1276549330.8736.104.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 12:17 +0100, Mel Gorman wrote:
> This patch adds an event for when pages are isolated en-masse from the
> LRU lists. This event augments the information available on LRU traffic
> and can be used to evaluate lumpy reclaim.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Larry Woodman <lwoodman@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
