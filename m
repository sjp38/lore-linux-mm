Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B70F6B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:25:42 -0400 (EDT)
Date: Thu, 16 Jul 2009 22:25:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: count only reclaimable lru pages
Message-ID: <20090716142533.GA27165@localhost>
References: <20090716133454.GA20550@localhost> <alpine.DEB.1.10.0907160959260.32382@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0907160959260.32382@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 16, 2009 at 10:00:51PM +0800, Christoph Lameter wrote:
> On Thu, 16 Jul 2009, Wu Fengguang wrote:
> 
> > When swap is full or not present, the anon lru lists are not reclaimable
> > and thus won't be scanned. So the anon pages shall not be counted. Also
> > rename the function names to reflect the new meaning.
> >
> > It can greatly (and correctly) increase the slab scan rate under high memory
> > pressure (when most file pages have been reclaimed and swap is full/absent),
> > thus avoid possible false OOM kills.
> 
> Reclaimable? Are all pages on the LRUs truly reclaimable?

No, only possibly reclaimable :)

What would you suggest?  In fact I'm not totally comfortable with it.
Maybe it would be safer to simply stick with the old _lru_pages naming?

Thanks,
Fengguang

> Aside from that nit.
> 
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
