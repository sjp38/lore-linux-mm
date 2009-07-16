Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5809E6B007E
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:28:17 -0400 (EDT)
Subject: Re: [PATCH] mm: count only reclaimable lru pages
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090716142533.GA27165@localhost>
References: <20090716133454.GA20550@localhost>
	 <alpine.DEB.1.10.0907160959260.32382@gentwo.org>
	 <20090716142533.GA27165@localhost>
Content-Type: text/plain
Date: Thu, 16 Jul 2009 16:28:11 +0200
Message-Id: <1247754491.6586.23.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-07-16 at 22:25 +0800, Wu Fengguang wrote:
> > Reclaimable? Are all pages on the LRUs truly reclaimable?
> 
> No, only possibly reclaimable :)
> 
> What would you suggest?  In fact I'm not totally comfortable with it.
> Maybe it would be safer to simply stick with the old _lru_pages
> naming?

Nah, I like the reclaimable name, these pages are at least potentially
reclaimable.

lru_pages() is definately not correct anymore since you exclude the
unevictable and possibly the anon pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
