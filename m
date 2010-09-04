Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BC95B6B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 20:54:06 -0400 (EDT)
Date: Fri, 3 Sep 2010 19:54:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100903162821.48ec57cc.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1009031950100.18051@router.home>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie> <1283504926-2120-3-git-send-email-mel@csn.ul.ie> <20100903155537.41f1a3a7.akpm@linux-foundation.org> <alpine.DEB.2.00.1009031811090.16264@router.home>
 <20100903162821.48ec57cc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Sep 2010, Andrew Morton wrote:

> > percpu counters must always be added up when their value is determined.
>
> Nope.  That's the difference between percpu_counter_read() and
> percpu_counter_sum().

Hmmm... Okay you can fold them therefore. That is analogous to what we do
in the _snapshot function now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
