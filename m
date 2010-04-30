Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BC8F76003C2
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 16:22:19 -0400 (EDT)
Message-ID: <4BDB3BDC.2050004@redhat.com>
Date: Fri, 30 Apr 2010 16:21:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie> <1272529930-29505-3-git-send-email-mel@csn.ul.ie> <20100429162120.GC22108@random.random> <20100430192235.GL22108@random.random>
In-Reply-To: <20100430192235.GL22108@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On 04/30/2010 03:22 PM, Andrea Arcangeli wrote:
> I'm building a mergeable THP+memory compaction tree ready for mainline
> merging based on new anon-vma code, so I'm integrating your patch1 and
> this below should be the port of my alternate fix to your patch2 to
> fix the longstanding crash in migrate (not a bug in new anon-vma code
> but longstanding). patch1 is instead about the bugs introduced by the
> new anon-vma code that might crash migrate (even without memory
> compaction and/or THP) the same way as the bug fixed by the below.
>
> ==
> Subject: fix race between shift_arg_pages and rmap_walk
>
> From: Andrea Arcangeli<aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
