Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 191F26B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 18:22:02 -0400 (EDT)
Message-ID: <4AA6D8D0.9050509@redhat.com>
Date: Tue, 08 Sep 2009 18:21:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] mm: follow_hugetlb_page flags
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909072235360.15430@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909072235360.15430@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> follow_hugetlb_page() shouldn't be guessing about the coredump case
> either: pass the foll_flags down to it, instead of just the write bit.
> 
> Remove that obscure huge_zeropage_ok() test.  The decision is easy,
> though unlike the non-huge case - here vm_ops->fault is always set.
> But we know that a fault would serve up zeroes, unless there's
> already a hugetlbfs pagecache page to back the range.
> 
> (Alternatively, since hugetlb pages aren't swapped out under pressure,
> you could save more dump space by arguing that a page not yet faulted
> into this process cannot be relevant to the dump; but that would be
> more surprising.)
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
