Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 01FC76B01EF
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 16:24:43 -0400 (EDT)
Subject: Re: [PATCH 36 of 41] remove PG_buddy
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1269888584.12097.371.camel@laptop>
References: <patchbomb.1269887833@v2.random>
	 <27d13ddf7c8f7ca03652.1269887869@v2.random>
	 <1269888584.12097.371.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Mar 2010 07:18:47 +1100
Message-ID: <1269893927.7101.19.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-29 at 20:49 +0200, Peter Zijlstra wrote:
> On Mon, 2010-03-29 at 20:37 +0200, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > PG_buddy can be converted to page->_count == -1. So the PG_compound_lock can be
> > added to page->flags without overflowing (because of the section bits
> > increasing) with CONFIG_X86_PAE=y.
> 
> This seems to break the assumption that all free pages have a zero page
> count relied upon by things like page_cache_get_speculative().
> 
> What if a page-cache pages gets freed and used as a head in the buddy
> list while a concurrent lockless page-cache lookup tries to get a page
> ref?

And here goes me wanting to hijack it for PG_arch_2 :-)

Is there any other page flag we could hijack ? I need it only when the
page is allocated, so a flag that's only used when the page sits in the
buddy would be fine.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
