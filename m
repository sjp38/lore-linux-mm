Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B044B6B01EE
	for <linux-mm@kvack.org>; Thu, 14 May 2009 13:49:06 -0400 (EDT)
Date: Thu, 14 May 2009 18:49:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
Message-ID: <20090514174947.GA24837@csn.ul.ie>
References: <bug-13302-10286@http.bugzilla.kernel.org/> <20090513130846.d463cc1e.akpm@linux-foundation.org> <20090514105326.GA11770@csn.ul.ie> <20090514105926.GB11770@csn.ul.ie> <6.2.5.6.2.20090514131734.05890270@binnacle.cx>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <6.2.5.6.2.20090514131734.05890270@binnacle.cx>
Sender: owner-linux-mm@kvack.org
To: starlight@binnacle.cx
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 01:20:09PM -0400, starlight@binnacle.cx wrote:
> At 11:59 AM 5/14/2009 +0100, Mel Gorman wrote:
> >Another question on top of this.
> >
> >At any point, do you call madvise(MADV_WILLNEED),
> >fadvise(FADV_WILLNEED) or readahead() on the share memory segment?
>
> Definately no.
> 
> The possibly unusual thing done is that a file is read into 
> something like 30% of the segment, and the remaining pages are 
> not touched.
> 

Ok, I just tried that there - parent writing 30% of the shared memory
before forking but still did not reproduce the problem :(

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
