Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 14A316B0047
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 06:33:39 -0500 (EST)
Date: Fri, 27 Feb 2009 12:33:33 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-ID: <20090227113333.GA21296@wotan.suse.de>
References: <20090223233030.GA26562@csn.ul.ie> <20090223155313.abd41881.akpm@linux-foundation.org> <20090224115126.GB25151@csn.ul.ie> <20090224160103.df238662.akpm@linux-foundation.org> <20090225160124.GA31915@csn.ul.ie> <20090225081954.8776ba9b.akpm@linux-foundation.org> <20090226163751.GG32756@csn.ul.ie> <alpine.DEB.1.10.0902261157100.7472@qirst.com> <20090226171549.GH32756@csn.ul.ie> <alpine.DEB.1.10.0902261226370.26440@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902261226370.26440@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, Feb 26, 2009 at 12:30:45PM -0500, Christoph Lameter wrote:
> On Thu, 26 Feb 2009, Mel Gorman wrote:
> 
> > > I tried the general use of a pool of zeroed pages back in 2005. Zeroing
> > > made sense only if the code allocating the page did not immediately touch
> > > the cachelines of the page.
> >
> > Any feeling as to how often this was the case?
> 
> Not often enough to justify the merging of my patches at the time. This
> was publicly discussed on lkml:
> 
> http://lkml.indiana.edu/hypermail/linux/kernel/0503.2/0482.html
> 
> > Indeed, any gain if it existed would be avoiding zeroing the pages used
> > by userspace. The cleanup would be reducing the amount of
> > architecture-specific code.
> >
> > I reckon it's worth an investigate but there is still other lower-lying
> > fruit.
> 
> I hope we can get rid of various ugly elements of the quicklists if the
> page allocator would offer some sort of support. I would think that the

Only if it provides significant advantages over existing quicklists or
adds *no* extra overhead to the page allocator common cases. :)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
