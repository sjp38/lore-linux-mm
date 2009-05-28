Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 80FAE6B0055
	for <linux-mm@kvack.org>; Thu, 28 May 2009 04:55:46 -0400 (EDT)
Date: Thu, 28 May 2009 09:56:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/2] Fixes for hugetlbfs-related problems on shared
	memory
Message-ID: <20090528085635.GC10334@csn.ul.ie>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie> <20090527131437.5870e342.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090527131437.5870e342.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@elte.hu, stable@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh.dickins@tiscali.co.uk, Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, starlight@binnacle.cx, ebmunson@us.ibm.com, agl@us.ibm.com, apw@canonical.com, wli@movementarian.org
List-ID: <linux-mm.kvack.org>

On Wed, May 27, 2009 at 01:14:37PM -0700, Andrew Morton wrote:
> On Wed, 27 May 2009 12:12:27 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > The following two patches are required to fix problems reported by
> > starlight@binnacle.cx. The tests cases both involve two processes interacting
> > with shared memory segments backed by hugetlbfs.
> 
> Thanks.
> 
> Both of these address http://bugzilla.kernel.org/show_bug.cgi?id=13302, yes?
> I added that info to the changelogs, to close the loop.
> 

Yes. I'm sorry, I should have included that information in the leader. I
had a niggling feeling I was forgetting something to add to the changelog -
this was it :)

> Ingo, I'd propose merging both these together rather than routing one
> via the x86 tree, OK?
> 
> Question is: when?  Are we confident enough to merge it into 2.6.30
> now, or should we hold off for 2.6.30.1?  I guess we have a week or
> more, and if the changes do break something, we can fix that in
> 2.6.30.1 ;)
> 

FWIW, I'm reasonably confident based on libhugetlbfs regression testing that
I haven't broken something new. If they make it into 2.6.30-rc8, so much
the better. Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
