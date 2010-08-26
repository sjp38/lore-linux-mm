Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B3CC06B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 09:32:17 -0400 (EDT)
Message-ID: <4C766CD7.8000004@redhat.com>
Date: Thu, 26 Aug 2010 09:32:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/26/2010 02:12 AM, Hugh Dickins wrote:
> After several hours, kbuild tests hang with anon_vma_prepare() spinning on
> a newly allocated anon_vma's lock - on a box with CONFIG_TREE_PREEMPT_RCU=y
> (which makes this very much more likely, but it could happen without).
>
> The ever-subtle page_lock_anon_vma() now needs a further twist: since
> anon_vma_prepare() and anon_vma_fork() are liable to change the ->root
> of a reused anon_vma structure at any moment, page_lock_anon_vma()
> needs to check page_mapped() again before succeeding, otherwise
> page_unlock_anon_vma() might address a different root->lock.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

And yes, AFAIK this code lived just in -mm up to now.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
