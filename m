Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 426746B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 09:51:50 -0400 (EDT)
Date: Tue, 28 Sep 2010 14:51:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20100928135148.GM8187@csn.ul.ie>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009280838540.6360@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009280838540.6360@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 28, 2010 at 08:40:15AM -0500, Christoph Lameter wrote:
> On Tue, 28 Sep 2010, Mel Gorman wrote:
> 
> > Which of these is better or is there an alternative suggestion on how
> > this livelock can be avoided?
> 
> We need to run some experiments to see what is worse. Lets start by
> cutting both the stats threshold and the drift thing in half?
> 

Ok, I have no problem with that although again, I'm really not in the position
to roll patches for it right now. I don't want to get side-tracked.

> > As a heads up, I'm preparing for exams at the moment and while I'm online, I'm
> > not in the position to prototype patches and test them at the moment but can
> > review alternative proposals if people have them. I'm also out early next week.
> 
> Exams? You are finally graduating?
> 

Depends on how they go :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
