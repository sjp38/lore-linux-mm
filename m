Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F2CFC6B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 07:26:21 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so226802rvb.26
        for <linux-mm@kvack.org>; Wed, 01 Jul 2009 04:27:10 -0700 (PDT)
Date: Wed, 1 Jul 2009 19:27:05 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090701112705.GA3102@localhost>
References: <20090701131734.85D9.A69D9226@jp.fujitsu.com> <20090701042554.GA14344@localhost> <20090701132757.85DC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090701132757.85DC.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 01, 2009 at 01:30:51PM +0900, KOSAKI Motohiro wrote:
> > > > The question is: Why kswapd reclaims are absent here?

Ah, maybe kswapd simply didn't have the opportunity to be scheduled
for running, because msgctl11 is busy forking thousands of processes?

> > > if direct reclaim isolate all pages, kswapd can't reclaim any pages.
> > 
> > OOM will occur in that condition. What happened before that time?
> 
> maybe yes, maybe no.
> At first test, the system still have droppable file cache. if direct
> reclaim luckly take it, the benchmark become successful end, I
> think.

Yes that's the main difference between first and second run. Note that
file cache can be dropped quickly, while the pageout of tmpfs pages
populated by msgctl11 itself takes time.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
