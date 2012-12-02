Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id EF76B6B0044
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 12:53:44 -0500 (EST)
Message-ID: <50BB9595.6040300@redhat.com>
Date: Sun, 02 Dec 2012 12:53:25 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2, v2] mm/migration: Make rmap_walk_anon() and try_to_unmap_anon()
 more scalable
References: <1354305521-11583-1-git-send-email-mingo@kernel.org> <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com> <20121201094927.GA12366@gmail.com> <20121201122649.GA20322@gmail.com> <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com> <20121201184135.GA32449@gmail.com> <CA+55aFyq7OaUxcEHXvJhp0T57KN14o-RGxqPmA+ks8ge6zJh5w@mail.gmail.com> <20121201201538.GB2704@gmail.com> <50BA69B7.30002@redhat.com> <20121202151232.GB12911@gmail.com>
In-Reply-To: <20121202151232.GB12911@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 12/02/2012 10:12 AM, Ingo Molnar wrote:

> Rename anon_vma_[un]lock() => anon_vma_[un]lock_write(),
> to make it clearer that it's an exclusive write-lock in
> that case - suggested by Rik van Riel.

... close, but you forgot to actually rename the unlock function :)

> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 7f5a552..81a9dee 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -101,7 +101,7 @@ extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
>   #define wait_split_huge_page(__anon_vma, __pmd)				\
>   	do {								\
>   		pmd_t *____pmd = (__pmd);				\
> -		anon_vma_lock(__anon_vma);				\
> +		anon_vma_lock_write(__anon_vma);			\
>   		anon_vma_unlock(__anon_vma);				\
>   		BUG_ON(pmd_trans_splitting(*____pmd) ||			\

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
