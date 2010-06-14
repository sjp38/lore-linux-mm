Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8843D6B01D4
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:57:37 -0400 (EDT)
Subject: Re: [PATCH 03/12] tracing, vmscan: Add trace event when a page is
	written
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <1276514273-27693-4-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	 <1276514273-27693-4-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 14 Jun 2010 17:02:51 -0400
Message-Id: <1276549371.8736.105.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 12:17 +0100, Mel Gorman wrote:
> This patch adds a trace event for when page reclaim queues a page for IO and
> records whether it is synchronous or asynchronous. Excessive synchronous
> IO for a process can result in noticeable stalls during direct reclaim.
> Excessive IO from page reclaim may indicate that the system is seriously
> under provisioned for the amount of dirty pages that exist.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Larry Woodman <lwoodman@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
