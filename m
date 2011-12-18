Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 7F3126B005A
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 19:19:02 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so7185643wgb.26
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 16:19:00 -0800 (PST)
Message-ID: <1324167535.3323.63.camel@edumazet-laptop>
Subject: Re: [PATCH] Put braces around potentially empty 'if' body in
 handle_pte_fault()
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 18 Dec 2011 01:18:55 +0100
In-Reply-To: <alpine.LNX.2.00.1112180059080.21784@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1112180059080.21784@swampdragon.chaosbits.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Le dimanche 18 dA(C)cembre 2011 A  01:03 +0100, Jesper Juhl a A(C)crit :
> If one builds the kernel with -Wempty-body one gets this warning:
> 
>   mm/memory.c:3432:46: warning: suggest braces around empty body in an a??ifa?? statement [-Wempty-body]
> 
> due to the fact that 'flush_tlb_fix_spurious_fault' is a macro that
> can sometimes be defined to nothing.
> 
> I suggest we heed gcc's advice and put a pair of braces on that if.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  mm/memory.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 829d437..9cf1b48 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3428,9 +3428,9 @@ int handle_pte_fault(struct mm_struct *mm,
>  		 * This still avoids useless tlb flushes for .text page faults
>  		 * with threads.
>  		 */
> -		if (flags & FAULT_FLAG_WRITE)
> +		if (flags & FAULT_FLAG_WRITE) {
>  			flush_tlb_fix_spurious_fault(vma, address);
> +		}
>  	}
>  unlock:
>  	pte_unmap_unlock(pte, ptl);
> -- 
> 1.7.8
> 

Thats should be fixed in the reverse way :

#define flush_tlb_fix_spurious_fault(vma, address) do { } while (0)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
