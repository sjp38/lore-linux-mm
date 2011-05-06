Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 01DBE90010B
	for <linux-mm@kvack.org>; Fri,  6 May 2011 12:00:12 -0400 (EDT)
Message-ID: <4DC41AF2.6000804@redhat.com>
Date: Fri, 06 May 2011 11:59:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] VM/RMAP: Batch anon vma chain root locking in fork
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org> <1304623972-9159-3-git-send-email-andi@firstfloor.org>
In-Reply-To: <1304623972-9159-3-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie, Andi Kleen <ak@linux.intel.com>

On 05/05/2011 03:32 PM, Andi Kleen wrote:
> From: Andi Kleen<ak@linux.intel.com>
>
> We found that the changes to take anon vma root chain lock lead
> to excessive lock contention on a fork intensive workload on a 4S
> system.
>
> Use the new batch lock infrastructure to optimize the fork()
> path, where it is very common to acquire always the same lock.
>
> This patch does not really lower the contention, but batches
> the lock taking/freeing to lower the bouncing overhead when
> multiple forks are working at the same time. Essentially each
> user will get more work done inside a locking region.
>
> Reported-by: Tim Chen<tim.c.chen@linux.intel.com>
> Cc: Andrea Arcangeli<aarcange@redhat.com>
> Cc: Rik van Riel<riel@redhat.com>
> Signed-off-by: Andi Kleen<ak@linux.intel.com>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
