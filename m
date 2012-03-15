Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id BED7C6B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 12:02:59 -0400 (EDT)
Message-ID: <4F621259.2090607@redhat.com>
Date: Thu, 15 Mar 2012 12:01:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: thp: fix pmd_bad() triggering in code paths holding
 mmap_sem read mode
References: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>

On 03/15/2012 10:44 AM, Andrea Arcangeli wrote:
> In some cases it may happen that pmd_none_or_clear_bad() is called
> with the mmap_sem hold in read mode. In those cases the huge page
> faults can allocate hugepmds under pmd_none_or_clear_bad() and that
> can trigger a false positive from pmd_bad() that will not like to see
> a pmd materializing as trans huge.
>
> It's not khugepaged the problem, khugepaged holds the mmap_sem in
> write mode (and all those sites must hold the mmap_sem in read mode to
> prevent pagetables to go away from under them, during code review it
> seems vm86 mode on 32bit kernels requires that too unless it's
> restricted to 1 thread per process or UP builds). The race is only
> with the huge pagefaults that can convert a pmd_none() into a
> pmd_trans_huge().

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
