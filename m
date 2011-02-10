Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 08A038D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:34:51 -0500 (EST)
Date: Thu, 10 Feb 2011 13:34:00 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/5] pagewalk: only split huge pages when necessary
Message-ID: <20110210133359.GI17873@csn.ul.ie>
References: <20110209195406.B9F23C9F@kernel> <20110209195407.2CE28EA0@kernel> <20110210111125.GC17873@csn.ul.ie> <20110210131928.GV3347@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110210131928.GV3347@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>

On Thu, Feb 10, 2011 at 02:19:28PM +0100, Andrea Arcangeli wrote:
> On Thu, Feb 10, 2011 at 11:11:25AM +0000, Mel Gorman wrote:
> > Before we goto this retry, there is at a cond_resched(). Just to confirm,
> > we are depending on mmap_sem to prevent khugepaged promoting this back to
> > a hugepage, right? I don't see a problem with that but I want to be
> > sure.
> 
> Correct, and we depend on that everywhere as wait_split_huge_page has
> to run without holding spinlocks.
> 

In that case;

Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
