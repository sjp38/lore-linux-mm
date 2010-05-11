Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 001EB6B0227
	for <linux-mm@kvack.org>; Tue, 11 May 2010 08:11:07 -0400 (EDT)
Message-ID: <4BE94935.9090200@redhat.com>
Date: Tue, 11 May 2010 08:10:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,migration: Avoid race between shift_arg_pages() and
 rmap_walk() during migration by not migrating temporary stacks
References: <20100511085752.GM26611@csn.ul.ie>
In-Reply-To: <20100511085752.GM26611@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On 05/11/2010 04:57 AM, Mel Gorman wrote:
> Hi Andrew,
>
> This patch closes the most important race in relation to exec and
> migration. With it applied, the swapops bug is no longer triggering for
> known problem workloads. If you pick it up, it should go with the other
> mmmigration-* fixes in mm.

> This patch causes pages within the temporary stack during exec to be skipped
> by migration. It does this by marking the VMA covering the temporary stack
> with an otherwise impossible combination of VMA flags. These flags are
> cleared when the temporary stack is moved to its final location.
>
> [kamezawa.hiroyu@jp.fujitsu.com: Idea for having migration skip temporary stacks]
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>
> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
