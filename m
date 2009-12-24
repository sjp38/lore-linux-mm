Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 08484620002
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 07:07:41 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBOC7WKs021071
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 17:37:32 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBOC7W803240064
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 17:37:32 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBOC7UB4021179
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 23:07:32 +1100
Date: Thu, 24 Dec 2009 17:37:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 28 of 28] memcg huge memory
Message-ID: <20091224120726.GE13983@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <patchbomb.1261076403@v2.random>
 <d9c8d2160feb7d82736b.1261076431@v2.random>
 <20091224100030.GD13983@balbir.in.ibm.com>
 <20091224114025.GK6429@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091224114025.GK6429@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Andrea Arcangeli <aarcange@redhat.com> [2009-12-24 12:40:25]:

> On Thu, Dec 24, 2009 at 03:30:30PM +0530, Balbir Singh wrote:
> > Charging huge pages might be OK, but I wonder if we should create a
> > separate counter since hugepages are not reclaimable.  I am yet to
> > look at the complete series, does this series make hugepages
> > reclaimable? Could you please update Documentation/cgroups/memcg* as
> > well.
> 
> The transparent hugepage that you quoted are reclaimable (actually
> swappable/pageable, reclaimable isn't exact term for them), but the
> point is that you can't see the different from userland so they can't
> deserve a special counter. The hugetlbfs pages (not in patch above)
> are still not swappable but they're not relevant with this
> patchset. The whole point of transparent hugepage is that the user
> shouldn't even notice they exist and it'll be the kernel to decide if
> it worth using them or not, and when to split them if needed. Apps
> however would better use madvise(MADV_HUGEPAGE) on large chunks of
> malloc memory that will benefit from hugepages, because certain users
> like embedded may want to turn off hugepages in all areas except the
> ones marked by madvise. Transparent Hugepages may or may not generate
> some minor memory and CPU waste depending on usage, so for memory
> constrained devices it worth enabling them only where they generate
> zero memory loss and zero CPU loss (even the prelloacted pte that is
> required to guarantee success of split_huge_page would have been
> allocated anyway if hugepages were disabled).

The concern with hugepages (not transparent), is that they are locked
and might cause frequent OOM. I think Kame raised this point as well.
Thanks for clarifying the patch though.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
