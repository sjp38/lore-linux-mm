Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A0D528D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 08:57:52 -0500 (EST)
Message-ID: <4D7635DA.9030707@redhat.com>
Date: Tue, 08 Mar 2011 08:57:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: THP, rmap and page_referenced_one()
References: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com> <AANLkTinncv11r3cJnOr0HWZyaSu5NQMz6pEYThMkmFd0@mail.gmail.com> <AANLkTikKtxEoXT=Y9d80oYnY7LvfLn8Hwz-XorSxR3Mv@mail.gmail.com> <20110308113245.GR25641@random.random>
In-Reply-To: <20110308113245.GR25641@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On 03/08/2011 06:32 AM, Andrea Arcangeli wrote:

> Subject: thp: fix page_referenced to modify mapcount/vm_flags only if page is found
>
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> When vmscan.c calls page_referenced, if an anon page was created before a
> process forked, rmap will search for it in both of the processes, even though
> one of them might have since broken COW. If the child process mlocks the vma
> where the COWed page belongs to, page_referenced() running on the page mapped
> by the parent would lead to *vm_flags getting VM_LOCKED set erroneously (leading
> to the references on the parent page being ignored and evicting the parent page
> too early).

> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> Reported-by: Michel Lespinasse<walken@google.com>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
