Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0AECD6B0092
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:43:25 -0400 (EDT)
Message-ID: <5092ECF1.4060706@redhat.com>
Date: Thu, 01 Nov 2012 17:43:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/6] mm: augment vma rbtree with rb_subtree_gap
References: <1351679605-4816-1-git-send-email-walken@google.com> <1351679605-4816-2-git-send-email-walken@google.com>
In-Reply-To: <1351679605-4816-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On 10/31/2012 06:33 AM, Michel Lespinasse wrote:
> Define vma->rb_subtree_gap as the largest gap between any vma in the
> subtree rooted at that vma, and their predecessor. Or, for a recursive
> definition, vma->rb_subtree_gap is the max of:
> - vma->vm_start - vma->vm_prev->vm_end
> - rb_subtree_gap fields of the vmas pointed by vma->rb.rb_left and
>    vma->rb.rb_right
>
> This will allow get_unmapped_area_* to find a free area of the right
> size in O(log(N)) time, instead of potentially having to do a linear
> walk across all the VMAs.
>
> Also define mm->highest_vm_end as the vm_end field of the highest vma,
> so that we can easily check if the following gap is suitable.
>
> This does have the potential to make unmapping VMAs more expensive,
> especially for processes with very large numbers of VMAs, where the
> VMA rbtree can grow quite deep.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
