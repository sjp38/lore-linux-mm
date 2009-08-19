Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F3D2F6B005D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 05:08:41 -0400 (EDT)
Date: Wed, 19 Aug 2009 10:08:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Reduce searching in the page allocator
	fast-path
Message-ID: <20090819090843.GB24809@csn.ul.ie>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0908181019130.32284@gentwo.org> <20090818165340.GB13435@csn.ul.ie> <alpine.DEB.1.10.0908181357100.3840@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0908181357100.3840@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 03:05:25PM -0400, Christoph Lameter wrote:
> On Tue, 18 Aug 2009, Mel Gorman wrote:
> 
> > Can you point me to which patchset you are talking about specifically that
> > uses per-cpu atomics in the hot path? There are a lot of per-cpu patches
> > related to you that have been posted in the last few months and I'm not sure
> > what any of their merge status' is.
> 
> The following patch just moved the page allocator to use the new per cpu
> allocator. It does not use per cpu atomic yet but its possible then.
> 
> http://marc.info/?l=linux-mm&m=124527414206546&w=2
> 

Ok, I don't see this particular patch merged, is it in a merge queue somewhere?

After glancing through, I can see how it might help.  I'm going to drop patch
3 of this set that shuffles data from the PCP to the zone and take a closer
look at those patches. Patch 1 and 2 of this set should still go ahead. Do
you agree?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
