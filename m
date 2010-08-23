Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 827996B03BC
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 09:38:34 -0400 (EDT)
Date: Mon, 23 Aug 2010 08:38:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] Reduce watermark-related problems with the per-cpu
 allocator V2
In-Reply-To: <20100823130127.GP19797@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1008230835220.5750@router.home>
References: <1282550442-15193-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1008230742300.4094@router.home> <20100823130127.GP19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010, Mel Gorman wrote:

> > The maximum time for which the livelock can exists is the vm stat
> > interval. By default the counters are brought up to date at least once per
> > second or if a certain delta was violated. Drifts are controlled by the
> > delta configuration.
> >
>
> While there is a maximum time (2 seconds I think) the drift can exist
> in, a machine under enough pressure can make a mess of the watermarks
> during that time. If it wasn't the case, these livelocks with 0 pages
> free wouldn't be happening.

So because we go way beyond the watermarks we reach a state in which a
livelock exists that does not go away when the counters are finally
updated?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
