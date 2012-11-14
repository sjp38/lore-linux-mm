Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id A3F2F6B005D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:22:46 -0500 (EST)
Message-ID: <50A3E169.4010402@redhat.com>
Date: Wed, 14 Nov 2012 13:22:33 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 26/31] sched: numa: Make mempolicy home-node aware
References: <1352805180-1607-1-git-send-email-mgorman@suse.de> <1352805180-1607-27-git-send-email-mgorman@suse.de>
In-Reply-To: <1352805180-1607-27-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/13/2012 06:12 AM, Mel Gorman wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
> Add another layer of fallback policy to make the home node concept
> useful from a memory allocation PoV.
>
> This changes the mpol order to:
>
>   - vma->vm_ops->get_policy	[if applicable]
>   - vma->vm_policy		[if applicable]
>   - task->mempolicy
>   - tsk_home_node() preferred	[NEW]
>   - default_policy

Why is the home node policy not the default policy?

> Note that the tsk_home_node() policy has Migrate-on-Fault enabled to
> facilitate efficient on-demand memory migration.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Paul Turner <pjt@google.com>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>




-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
