Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CD8536B0071
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 11:14:11 -0500 (EST)
Date: Wed, 3 Feb 2010 10:13:12 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 32 of 32] khugepaged
In-Reply-To: <20100202202450.GR4135@random.random>
Message-ID: <alpine.DEB.2.00.1002031010170.6590@router.home>
References: <patchbomb.1264969631@v2.random> <51b543fab38b1290f176.1264969663@v2.random> <alpine.DEB.2.00.1002011551560.2384@router.home> <20100201225624.GB4135@random.random> <alpine.DEB.2.00.1002021347520.19529@router.home>
 <20100202202450.GR4135@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Feb 2010, Andrea Arcangeli wrote:

> How would you say it? I think if ksm was forced to the migration pte
> like it was discussed when ksm was first submitted, I would definitely
> be forced to use it here too in order to get it merged. Do you disagree?

How about at least consolidating the code with ksm pieces?

> I prefer not to reuse the migration pte. I prefer to stick to the ksm
> method. My rationale is pretty simple, migration pte requires an
> additional logic in the pagefault code, while this doesn't and so it
> has less dependencies and it looks simpler and more self contained to
> me and it is enough for khugepaged as it is enough for ksm.

The logic is already there ready for use.

> pte freezing (ksm) or pmd_huge freezing (khugepaged). I think what
> you're asking is over-engineering but again I welcome you to do it
> yourself and prove you actually save lines, I don't see it myself. I
> think if it was it so obvious as you pretend it to be, Hugh would have
> cleaned it up considering it was an issue mentioned already.

I am asking for simplification and that you do the cleanup work that comes
with introcing new functionality in the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
