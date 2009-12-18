Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 354726B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:48:07 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBIIf76p028883
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 11:41:07 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBIIlZWD121876
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 11:47:37 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBIIlVeP011420
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 11:47:32 -0700
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <patchbomb.1261076403@v2.random>
References: <patchbomb.1261076403@v2.random>
Content-Type: text/plain
Date: Fri, 18 Dec 2009 10:47:29 -0800
Message-Id: <1261162049.27372.1649.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-12-17 at 19:00 +0000, Andrea Arcangeli wrote:
> This is an update of my status on the transparent hugepage patchset. Quite
> some changes happened in the last two weeks as I handled all feedback
> provided so far (notably from Avi, Andi, Nick and others), and continuted on
> the original todo list.

For what it's worth, I went trying to do some of this a few months ago
to see how feasible it was.  I ended up doing a bunch of the same stuff
like having the preallocated pte_page() hanging off the mm.  I think I
tied directly into the pte_offset_*() functions instead of introducing
new ones, but the concept was the same: as much as possible *don't*
teach the VM about huge pages, split them.

I ended up getting hung up on some of the PMD locking, and I think using
the PMD bit like that is a fine solution.  The way these are split up
also looks good to me.

Except for some of the stuff in put_compound_page(), these look pretty
sane to me in general.  I'll go through them in more detail after the
holidays.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
