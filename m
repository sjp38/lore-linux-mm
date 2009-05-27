Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 015F16B00B6
	for <linux-mm@kvack.org>; Wed, 27 May 2009 19:20:04 -0400 (EDT)
Date: Thu, 28 May 2009 01:19:49 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] Fixes for hugetlbfs-related problems on shared
	memory
Message-ID: <20090527231949.GB30002@elte.hu>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie> <20090527131437.5870e342.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090527131437.5870e342.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh.dickins@tiscali.co.uk, Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, starlight@binnacle.cx, ebmunson@us.ibm.com, agl@us.ibm.com, apw@canonical.com, wli@movementarian.org
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 27 May 2009 12:12:27 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > The following two patches are required to fix problems reported by
> > starlight@binnacle.cx. The tests cases both involve two processes interacting
> > with shared memory segments backed by hugetlbfs.
> 
> Thanks.
> 
> Both of these address 
> http://bugzilla.kernel.org/show_bug.cgi?id=13302, yes? I added 
> that info to the changelogs, to close the loop.
> 
> Ingo, I'd propose merging both these together rather than routing 
> one via the x86 tree, OK?

sure.

> Question is: when?  Are we confident enough to merge it into 
> 2.6.30 now, or should we hold off for 2.6.30.1?  I guess we have a 
> week or more, and if the changes do break something, we can fix 
> that in 2.6.30.1 ;)

With an Acked-by from Hugh i feel pretty confident about it - and as 
long as it get into -rc8 i think we should do it in .30.

	Ingo 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
