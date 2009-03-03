Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A44506B009E
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 08:52:58 -0500 (EST)
Date: Tue, 3 Mar 2009 13:52:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-ID: <20090303135254.GE10577@csn.ul.ie>
References: <20090224115126.GB25151@csn.ul.ie> <20090224160103.df238662.akpm@linux-foundation.org> <20090225160124.GA31915@csn.ul.ie> <20090225081954.8776ba9b.akpm@linux-foundation.org> <20090226163751.GG32756@csn.ul.ie> <alpine.DEB.1.10.0902261157100.7472@qirst.com> <20090226171549.GH32756@csn.ul.ie> <alpine.DEB.1.10.0902261226370.26440@qirst.com> <20090227113333.GA21296@wotan.suse.de> <alpine.DEB.1.10.0902271039440.31801@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902271039440.31801@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 27, 2009 at 10:40:17AM -0500, Christoph Lameter wrote:
> On Fri, 27 Feb 2009, Nick Piggin wrote:
> 
> > > I hope we can get rid of various ugly elements of the quicklists if the
> > > page allocator would offer some sort of support. I would think that the
> >
> > Only if it provides significant advantages over existing quicklists or
> > adds *no* extra overhead to the page allocator common cases. :)
> 
> And only if the page allocator gets fast enough to be usable for
> allocs instead of quicklists.
> 

It appears the x86 doesn't even use the quicklists. I know patches for
i386 support used to exist, what happened with them?

That aside, I think we could win slightly by just knowing when a page is
zeroed and being freed back to the allocator such as when the quicklists
are being drained. I wrote a patch along those lines but it started
getting really messy on x86 so I'm postponing it for the moment.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
