Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 730466B0078
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 15:41:34 -0500 (EST)
Date: Thu, 21 Jan 2010 14:40:41 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 22 of 30] pmd_trans_huge migrate bugcheck
In-Reply-To: <f5766ea214603fc6a64f.1264054846@v2.random>
Message-ID: <alpine.DEB.2.00.1001211431300.13130@router.home>
References: <patchbomb.1264054824@v2.random> <f5766ea214603fc6a64f.1264054846@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 2010, Andrea Arcangeli wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
>
> No pmd_trans_huge should ever materialize in migration ptes areas, because
> try_to_unmap will split the hugepage before migration ptes are instantiated.

try_to_unmap? How do you isolate the hugepages from the LRU? If you do
isolate the huge pages via a LRU and get a 2M page then the migration
logic has to be modified to be aware that huge pages may split during try_to_unmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
