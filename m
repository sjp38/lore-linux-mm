Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 78DF56B0085
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:39:41 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C11FA82C5BD
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:58:56 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KwHHx2WDmI2Y for <linux-mm@kvack.org>;
	Thu, 16 Jul 2009 10:58:56 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AE6B582C658
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:58:46 -0400 (EDT)
Date: Thu, 16 Jul 2009 10:39:17 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm: count only reclaimable lru pages
In-Reply-To: <1247754491.6586.23.camel@laptop>
Message-ID: <alpine.DEB.1.10.0907161037590.7930@gentwo.org>
References: <20090716133454.GA20550@localhost>  <alpine.DEB.1.10.0907160959260.32382@gentwo.org>  <20090716142533.GA27165@localhost> <1247754491.6586.23.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009, Peter Zijlstra wrote:

> > What would you suggest?  In fact I'm not totally comfortable with it.
> > Maybe it would be safer to simply stick with the old _lru_pages
> > naming?
>
> Nah, I like the reclaimable name, these pages are at least potentially
> reclaimable.
>
> lru_pages() is definately not correct anymore since you exclude the
> unevictable and possibly the anon pages.

Well lets at least add a comment at the beginning of the functions
explaining that these are potentially reclaimable and list some of the
types of pages that may not be reclaimable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
