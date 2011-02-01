Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 189288D0039
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 04:58:17 -0500 (EST)
Date: Tue, 1 Feb 2011 10:58:08 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH 1/6] count transparent hugepage splits
Message-ID: <20110201095808.GG19534@cmpxchg.org>
References: <20110201003357.D6F0BE0D@kernel>
 <20110201003358.98826457@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110201003358.98826457@kernel>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 04:33:58PM -0800, Dave Hansen wrote:
> 
> The khugepaged process collapses transparent hugepages for us.  Whenever
> it collapses a page into a transparent hugepage, we increment a nice
> global counter exported in sysfs:
> 
> 	/sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed
> 
> But, transparent hugepages also get broken down in quite a few
> places in the kernel.  We do not have a good idea how how many of
> those collpased pages are "new" versus how many are just fixing up
> spots that got split a moment before.
> 
> Note: "splits" and "collapses" are opposites in this context.
> 
> This patch adds a new sysfs file:
> 
> 	/sys/kernel/mm/transparent_hugepage/pages_split
> 
> It is global, like "pages_collapsed", and is incremented whenever any
> transparent hugepage on the system has been broken down in to normal
> PAGE_SIZE base pages.  This way, we can get an idea how well khugepaged
> is keeping up collapsing pages that have been split.
> 
> I put it under /sys/kernel/mm/transparent_hugepage/ instead of the
> khugepaged/ directory since it is not strictly related to
> khugepaged; it can get incremented on pages other than those
> collapsed by khugepaged.
> 
> The variable storing this is a plain integer.  I needs the same
> amount of locking that 'khugepaged_pages_collapsed' has, for
> instance.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
