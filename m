Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C52F36B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 00:31:24 -0400 (EDT)
Date: Sun, 18 Apr 2010 21:32:38 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100418213238.2e62eac7@infradead.org>
In-Reply-To: <20100419010805.GD2520@dastard>
References: <20100414155233.D153.A69D9226@jp.fujitsu.com>
	<20100414072830.GK2493@dastard>
	<20100414085132.GJ25756@csn.ul.ie>
	<20100415013436.GO2493@dastard>
	<20100415102837.GB10966@csn.ul.ie>
	<20100416041412.GY2493@dastard>
	<20100416151403.GM19264@csn.ul.ie>
	<20100417203239.dda79e88.akpm@linux-foundation.org>
	<20100419003556.GC2520@dastard>
	<20100418174944.7b9716ad@infradead.org>
	<20100419010805.GD2520@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Apr 2010 11:08:05 +1000
Dave Chinner <david@fromorbit.com> wrote:

> > Maybe we need to do the background dirty writes a bit more
> > aggressive... or play with heuristics where we get an adaptive
> > timeout (say, if the file got closed by the last opener, then do a
> > shorter timeout)
> 
> Realistically, I'm concerned about preventing the worst case
> behaviour from occurring - making the background writes more
> agressive without preventing writeback in LRU order simply means it
> will be harder to test the VM corner case that triggers these
> writeout patterns...


while I appreciate that the worst case should not be uber horrific...
I care a LOT about getting the normal case right... and am willing to
sacrifice the worst case for that.. (obviously not to infinity, it
needs to be bounded)

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
