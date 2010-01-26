Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 389C46003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 10:55:37 -0500 (EST)
Date: Tue, 26 Jan 2010 09:54:59 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
In-Reply-To: <4B5E3CC0.2060006@redhat.com>
Message-ID: <alpine.DEB.2.00.1001260947580.23549@router.home>
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random> <alpine.DEB.2.00.1001251529070.5379@router.home>
 <4B5E3CC0.2060006@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 2010, Rik van Riel wrote:

> What exactly do you need the stable huge pages for?

Reduce VM overhead that arises because we have to handle memory in 4k
chunks. I.e. we have to submit 512 descriptors for 4k page sized chunks to
do I/O. get_user_pages has to pin 512 pages to get a safe reference.
Reclaim has to scan 4k chunks of memory. As the amount of memory increases
so does the number of metadatachunks that have to be handled by the VM and
the I/O subsystem.

> Want to send in an incremental patch that can temporarily block
> the pageout code from splitting up a huge page, so your direct
> users of huge pages can rely on them sticking around until the
> transaction is done?

Do we need the splitting? It seems that Andrea's firefox never needs to
split a huge page anyways.... ;-)

> > I still think we should get transparent huge page support straight up
> > first without complicated fallback schemes that makes huge pages difficult
> > to use.
>
> Without swapping, they will become difficult to use for system
> administrators, at least in the workloads we care about.

Huge pages are already in use through hugetlbs for such workloads. That
works without swap. So why is this suddenly such a must have requirement?

Why not swap 2M huge pages as a whole?


> I understand that your workloads may be different.

What in your workload forces hugetlb swap use? Just leaving a certain
percentage of memory for 4k pages addresses the issue right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
