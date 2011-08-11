Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC4C6B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 05:13:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4DA893EE0AE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:13:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 332313266C2
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:13:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B1F745DE3E
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:13:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0920A1DB8054
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:13:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C3A5B1DB804C
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 18:13:03 +0900 (JST)
Date: Thu, 11 Aug 2011 18:05:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/7] mm: vmscan: Remove dead code related to lumpy
 reclaim waiting on pages under writeback
Message-Id: <20110811180541.7412a61b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1312973240-32576-3-git-send-email-mgorman@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
	<1312973240-32576-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, 10 Aug 2011 11:47:15 +0100
Mel Gorman <mgorman@suse.de> wrote:

> Lumpy reclaim worked with two passes - the first which queued pages for
> IO and the second which waited on writeback. As direct reclaim can no
> longer write pages there is some dead code. This patch removes it but
> direct reclaim will continue to wait on pages under writeback while in
> synchronous reclaim mode.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
