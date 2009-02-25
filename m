Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CFE996B00D0
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 19:01:55 -0500 (EST)
Date: Tue, 24 Feb 2009 16:01:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-Id: <20090224160103.df238662.akpm@linux-foundation.org>
In-Reply-To: <20090224115126.GB25151@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	<1235344649-18265-21-git-send-email-mel@csn.ul.ie>
	<20090223013723.1d8f11c1.akpm@linux-foundation.org>
	<20090223233030.GA26562@csn.ul.ie>
	<20090223155313.abd41881.akpm@linux-foundation.org>
	<20090224115126.GB25151@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, hannes@cmpxchg.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 2009 11:51:26 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> > > Almost the opposite with steady improvements almost all the way through.
> > > 
> > > With the patch applied, we are still using hot/cold information on the
> > > allocation side so I'm somewhat surprised the patch even makes much of a
> > > difference. I'd have expected the pages being freed to be mostly hot.
> > 
> > Oh yeah.  Back in the ancient days, hot-cold-pages was using separate
> > magazines for hot and cold pages.  Then Christoph went and mucked with
> > it, using a single queue.  That might have affected things.
> > 
> 
> It might have. The impact is that requests for cold pages can get hot pages
> if there are not enough cold pages in the queue so readahead could prevent
> an active process getting cache hot pages. I don't think that would have
> showed up in the microbenchmark though.

We switched to doing non-temporal stores in copy_from_user(), didn't
we?  That would rub out the benefit which that microbenchmark
demonstrated?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
