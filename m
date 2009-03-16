Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 70E536B006A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:58:51 -0400 (EDT)
Date: Mon, 16 Mar 2009 16:58:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 23/35] Update NR_FREE_PAGES only as necessary
Message-ID: <20090316165848.GQ24293@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-24-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161214080.32577@qirst.com> <20090316164238.GK24293@csn.ul.ie> <alpine.DEB.1.10.0903161248130.13534@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903161248130.13534@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 12:48:25PM -0400, Christoph Lameter wrote:
> On Mon, 16 Mar 2009, Mel Gorman wrote:
> 
> > Replaced with
> >
> > __mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> 
> A later patch does that also.
> 

Silly of me. That later patch is in the "controversial" pile but the
change is now moved back here where it belongs.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
