Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 455F56B0047
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 06:38:20 -0500 (EST)
Date: Fri, 27 Feb 2009 12:38:13 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-ID: <20090227113813.GB21296@wotan.suse.de>
References: <20090223013723.1d8f11c1.akpm@linux-foundation.org> <20090223233030.GA26562@csn.ul.ie> <20090223155313.abd41881.akpm@linux-foundation.org> <20090224115126.GB25151@csn.ul.ie> <20090224160103.df238662.akpm@linux-foundation.org> <20090225160124.GA31915@csn.ul.ie> <20090225081954.8776ba9b.akpm@linux-foundation.org> <20090226163751.GG32756@csn.ul.ie> <alpine.DEB.1.10.0902261157100.7472@qirst.com> <20090226171549.GH32756@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090226171549.GH32756@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, Feb 26, 2009 at 05:15:49PM +0000, Mel Gorman wrote:
> On Thu, Feb 26, 2009 at 12:00:22PM -0500, Christoph Lameter wrote:
> > I tried the general use of a pool of zeroed pages back in 2005. Zeroing
> > made sense only if the code allocating the page did not immediately touch
> > the cachelines of the page.
> 
> Any feeling as to how often this was the case?

IMO background zeroing or anything like that is only going to
become less attractive. Heat and energy considerations are
relatively increasing, so doing speculative work in the kernel
is going to become relatively more costly. Especially in this
case where you use nontemporal stores or otherwise reduce the
efficiency of the CPU caches (and increase activity on bus and
memory).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
