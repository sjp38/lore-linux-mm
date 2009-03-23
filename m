Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DBB606B00D7
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 06:51:31 -0400 (EDT)
Date: Mon, 23 Mar 2009 11:55:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: oom-killer killing even if memory is available?
Message-ID: <20090323115531.GA15416@csn.ul.ie>
References: <20090317100049.33f67964@osiris.boeblingen.de.ibm.com> <20090317024605.846420e1.akpm@linux-foundation.org> <20090320152700.GM24586@csn.ul.ie> <20090320140255.e0c01a59.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090320140255.e0c01a59.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andreas Krebbel <krebbel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 20, 2009 at 02:02:55PM -0700, Andrew Morton wrote:
> On Fri, 20 Mar 2009 15:27:00 +0000 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > > 
> > > Something must have allocated (and possibly leaked) it.
> > > 
> > 
> > This looks like a memory leak all right. There used to be a patch that
> > recorded a stack trace for every page allocation but it was dropped from
> > -mm ages ago because of a merge conflict. I didn't revive it at the time
> > because it wasn't of immediate concern.
> > 
> > Should I revive the patch or do we have preferred ways of tracking down
> > memory leaks these days?
> 
> We know that a dentry is getting leaked but afaik we don't know which one
> or why.
> 
> We could get more info via the page-owner-tracking-leak-detector.patch
> approach, or by dumping the info in the cached dentries - I think Wu
> Fengguang prepared a patch which does that.
> 

Looks like it

> I'm not sure why I dropped page-owner-tracking-leak-detector.patch actually
> - it was pretty useful sometimes and afaik we still haven't merged any tool
> which duplicates it.
> 

The note I got at the time was "This patch was dropped because procfs
changes broke it".

> Here's the latest version which I have:
> 

That matches what I have. I'll check and see can I figure out what broke
with it.

> From: Alexander Nyberg <alexn@dsv.su.se>
> 
> Introduces CONFIG_PAGE_OWNER that keeps track of the call chain under which a
> page was allocated.  Includes a user-space helper in
> Documentation/page_owner.c to sort the enormous amount of output that this may
> give (thanks tridge).
> 
> <SNIP>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
