Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 151766B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 00:25:13 -0400 (EDT)
Received: by pxi33 with SMTP id 33so523509pxi.12
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 21:25:59 -0700 (PDT)
Date: Wed, 1 Jul 2009 12:25:54 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090701042554.GA14344@localhost>
References: <4A4AD07E.2040508@redhat.com> <20090701040649.GA12832@localhost> <20090701131734.85D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090701131734.85D9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 01, 2009 at 01:18:39PM +0900, KOSAKI Motohiro wrote:
> > On Tue, Jun 30, 2009 at 10:57:02PM -0400, Rik van Riel wrote:
> > > KOSAKI Motohiro wrote:
> > >
> > >>> [ 1522.019259] Active_anon:11 active_file:6 inactive_anon:0
> > >>> [ 1522.019260]  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
> > >>> [ 1522.019261]  free:1985 slab:44399 mapped:132 pagetables:61830 bounce:0
> > >>> [ 1522.019262]  isolate:69817
> > >>
> > >> OK. thanks.
> > >> I plan to submit this patch after small more tests. it is useful for OOM analysis.
> > >
> > > It is also useful for throttling page reclaim.
> > >
> > > If more than half of the inactive pages in a zone are
> > > isolated, we are probably beyond the point where adding
> > > additional reclaim processes will do more harm than good.
> > 
> > There are probably more problems in this case. For example,
> > followed is the vmstat after first (successful) run of msgctl11.
> > 
> > The question is: Why kswapd reclaims are absent here?
> 
> if direct reclaim isolate all pages, kswapd can't reclaim any pages.

OOM will occur in that condition. What happened before that time?

> I believe Rik's idea solve this problem.

Me too :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
