Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 365FE6B0078
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 16:38:33 -0400 (EDT)
Message-ID: <4C912EC2.5090405@redhat.com>
Date: Wed, 15 Sep 2010 16:38:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix rmap walk during fork
References: <20100915171657.GP5981@random.random>
In-Reply-To: <20100915171657.GP5981@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On 09/15/2010 01:16 PM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> The below bug in fork lead to the rmap walk finding the parent huge-pmd twice
> instead of just one, because the anon_vma_chain objects of the child vma still
> point to the vma->vm_mm of the parent. The below patch fixes it by making the
> rmap walk accurate during fork. It's not a big deal normally but it
> worth being accurate considering the cost is the same.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
