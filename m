Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 82A1C8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 10:46:41 -0500 (EST)
Message-ID: <4D7A3CC7.1010008@redhat.com>
Date: Fri, 11 Mar 2011 10:16:23 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] thp: mremap support and TLB optimization
References: <20110311020410.GH5641@random.random>
In-Reply-To: <20110311020410.GH5641@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>

On 03/10/2011 09:04 PM, Andrea Arcangeli wrote:
> Hello everyone,
>
> I've been wondering why mremap is sending one IPI for each page that
> it moves. I tried to remove that so we send an IPI for each
> vma/syscall (not for each pte/page). I also added native THP support
> without calling split_huge_page unconditionally if both the source and
> destination alignment allows a pmd_trans_huge to be preserved (the
> mremap extension and truncation already preserved existing hugepages
> but the move into new place didn't yet). If the destination alignment
> isn't ok, split_huge_page is unavoidable but that is an
> userland/hardware limitation, not really something we can optimize
> further in the kernel.
>
> I've no real numbers yet (volanomark results are mostly unchanged,
> it's a tinybit faster but it may be measurement error, and it doesn't
> seem to call mremap enough, but the thp_split number in /proc/vmstat
> seem to go down close to zero, maybe other JIT workloads will
> benefit?).

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
