Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AD0F56B0078
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 16:35:35 -0500 (EST)
Date: Thu, 18 Feb 2010 21:35:18 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05/12] Memory compaction core
Message-ID: <20100218213518.GD30258@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-6-git-send-email-mel@csn.ul.ie> <20100216170014.7309.A69D9226@jp.fujitsu.com> <20100216084800.GC26086@csn.ul.ie> <alpine.DEB.2.00.1002160849460.18275@router.home> <20100216145943.GA997@csn.ul.ie> <alpine.DEB.2.00.1002181335270.7351@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002181335270.7351@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 18, 2010 at 01:37:35PM -0600, Christoph Lameter wrote:
> On Tue, 16 Feb 2010, Mel Gorman wrote:
> 
> > > Oh there are numerous ZONE_DMA pressure issues if you have ancient /
> > > screwed up hardware that can only operate on DMA or DMA32 memory.
> > >
> >
> > I've never ran into the issue. I was under the impression that the only
> > device that might care these days are floopy disks.
> 
> Kame-san had an issue a year or so ago.
> 

Will add it as a potential follow-on then. I consider Unevictable more
important than zone-pressure issues. Neither are going to be done in the
first pass. It's complex enough as it is and I'm more concerned with
getting teh page migration anon_vma snag ironed out. Can you review the
patches related to page migration in v3 please and see what you think?
You are much more familiar with the intent of that area than I.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
