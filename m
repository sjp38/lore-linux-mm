Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCD56B0047
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:52:27 -0400 (EDT)
Date: Mon, 23 Mar 2009 14:59:21 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/25] Cleanup and optimise the page allocator V5
Message-ID: <20090323145921.GC15416@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903201059240.3740@qirst.com> <20090320153723.GO24586@csn.ul.ie> <alpine.DEB.1.10.0903201205260.18010@qirst.com> <20090320162716.GP24586@csn.ul.ie> <alpine.DEB.1.10.0903201503040.11746@qirst.com> <20090323115213.GC6484@csn.ul.ie> <alpine.DEB.1.10.0903230929440.7254@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903230929440.7254@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 23, 2009 at 09:30:26AM -0400, Christoph Lameter wrote:
> On Mon, 23 Mar 2009, Mel Gorman wrote:
> 
> > This came up again. There was some evidence when it was introduced that
> > it worked and micro-benchmarks can show it to be of some use. It's
> > not-obvious-enough that I'd be wary of deleting it.
> 
> Certainly there is some minimal benefit. But maybe that benefit will
> vanish if you drop the doubly linked list?
> 

Extremely difficult to tell. It only makes a difference if you are not
over a cache-line boundary using a singly linked list. If the structure
is within a cache-line boundary with either single or double linked
lists, it probably makes no measurable difference.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
