Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB3B6B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 23:17:16 -0400 (EDT)
Date: Fri, 3 Sep 2010 20:21:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-Id: <20100903202101.f937b0bb.akpm@linux-foundation.org>
In-Reply-To: <20100904022545.GD705@dastard>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie>
	<1283504926-2120-4-git-send-email-mel@csn.ul.ie>
	<20100903160026.564fdcc9.akpm@linux-foundation.org>
	<20100904022545.GD705@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, 4 Sep 2010 12:25:45 +1000 Dave Chinner <david@fromorbit.com> wrote:

> Still, given the improvements in performance from this patchset,
> I'd say inclusion is a no-braniner....

OK, thanks.

It'd be interesting to check the IPI frequency with and without -
/proc/interrupts "CAL" field.  Presumably it went down a lot.

I wouldn't bust a gut over it though :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
