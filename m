Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 09FA66B0074
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:37:56 -0500 (EST)
Message-ID: <50A3E4F7.5010807@redhat.com>
Date: Wed, 14 Nov 2012 13:37:43 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] sched, numa, mm: Count WS scanning against present
 PTEs, not virtual memory ranges
References: <1352883029-7885-1-git-send-email-mingo@kernel.org> <1352883029-7885-2-git-send-email-mingo@kernel.org>
In-Reply-To: <1352883029-7885-2-git-send-email-mingo@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

On 11/14/2012 03:50 AM, Ingo Molnar wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
> By accounting against the present PTEs, scanning speed reflects the
> actual present (mapped) memory.
>
> For this we modify mm/mprotect.c::change_protection() to return the
> number of ptes modified. (No change in functionality.)

We need to figure out what we actually want here.

Do we want to mark 256MB as non-present, or do we want to leave
behind 256MB of non-present (NUMA) memory? :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
