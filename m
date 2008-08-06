Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m76Jopjf010117
	for <linux-mm@kvack.org>; Wed, 6 Aug 2008 15:50:51 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m76JopFl207888
	for <linux-mm@kvack.org>; Wed, 6 Aug 2008 15:50:51 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m76Jopeh032540
	for <linux-mm@kvack.org>; Wed, 6 Aug 2008 15:50:51 -0400
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080806090222.GD21190@csn.ul.ie>
References: <20080730172317.GA14138@csn.ul.ie>
	 <20080730103407.b110afc2.akpm@linux-foundation.org>
	 <20080730193010.GB14138@csn.ul.ie>
	 <20080730130709.eb541475.akpm@linux-foundation.org>
	 <20080731103137.GD1704@csn.ul.ie> <1217884211.20260.144.camel@nimitz>
	 <20080805111147.GD20243@csn.ul.ie> <1217952748.10907.18.camel@nimitz>
	 <20080805162800.GJ20243@csn.ul.ie> <1217958805.10907.45.camel@nimitz>
	 <20080806090222.GD21190@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 06 Aug 2008 12:50:49 -0700
Message-Id: <1218052249.10907.125.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-08-06 at 10:02 +0100, Mel Gorman wrote:
> > That said, this particular patch doesn't appear *too* bound to hugetlb
> > itself.  But, some of its limitations *do* come from the filesystem,
> > like its inability to handle VM_GROWS...  
> 
> The lack of VM_GROWSX is an issue, but on its own it does not justify
> the amount of churn necessary to support direct pagetable insertions for
> MAP_ANONYMOUS|MAP_PRIVATE. I think we'd need another case or two that would
> really benefit from direct insertions to pagetables instead of hugetlbfs so
> that the path would get adequately tested.

I'm jumping around here a bit, but I'm trying to get to the core of what
my problem with these patches is.  I'll see if I can close the loop
here.

The main thing this set of patches does that I care about is take an
anonymous VMA and replace it with a hugetlb VMA.  It does this on a
special cue, but does it nonetheless.

This patch has crossed a line in that it is really the first
*replacement* of a normal VMA with a hugetlb VMA instead of the creation
of the VMAs at the user's request.  I'm really curious what the plan is
to follow up on this.  Will this stack stuff turn out to be one-off
code, or is this *the* route for getting transparent large pages in the
future?

Because of the limitations like its inability to grow the VMA, I can't
imagine that this would be a generic mechanism that we can use
elsewhere.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
