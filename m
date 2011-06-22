Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AB8A8900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:04:51 -0400 (EDT)
Message-ID: <4E0274FC.5070505@redhat.com>
Date: Wed, 22 Jun 2011 19:04:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fadvise: move active pages to inactive list with
 POSIX_FADV_DONTNEED
References: <1308779480-4950-1-git-send-email-andrea@betterlinux.com>
In-Reply-To: <1308779480-4950-1-git-send-email-andrea@betterlinux.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/22/2011 05:51 PM, Andrea Righi wrote:
> There were some reported problems in the past about trashing page cache
> when a backup software (i.e., rsync) touches a huge amount of pages (see
> for example [1]).
>
> This problem has been almost fixed by the Minchan Kim's patch [2] and a
> proper use of fadvise() in the backup software. For example this patch
> set [3] has been proposed for inclusion in rsync.
>
> However, there can be still other similar trashing problems: when the
> backup software reads all the source files, some of them may be part of
> the actual working set of the system. When a
> posix_fadvise(POSIX_FADV_DONTNEED) is performed _all_ pages are evicted
> from pagecache, both the working set and the use-once pages touched only
> by the backup software.
>
> With the following solution when posix_fadvise(POSIX_FADV_DONTNEED) is
> called for an active page instead of removing it from the page cache it
> is added to the tail of the inactive list. Otherwise, if it's already in
> the inactive list the page is removed from the page cache.

> Signed-off-by: Andrea Righi<andrea@betterlinux.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
