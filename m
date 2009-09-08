Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 559DD6B0082
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 14:14:30 -0400 (EDT)
Date: Tue, 8 Sep 2009 19:13:46 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mmap : remove unnecessary code
In-Reply-To: <1252377494-9187-1-git-send-email-shijie8@gmail.com>
Message-ID: <Pine.LNX.4.64.0909081912290.4120@sister.anvils>
References: <1252377494-9187-1-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009, Huang Shijie wrote:

> If (flags & MAP_LOCKED) is true, it means vm_flags has already contained
> the bit VM_LOCKED which is set by calc_vm_flag_bits().
> 
> So there is no need to reset it again, just remove it.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
>  mm/mmap.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 8101de4..6b240ce 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -965,11 +965,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
>  			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
>  
> -	if (flags & MAP_LOCKED) {
> +	if (flags & MAP_LOCKED)
>  		if (!can_do_mlock())
>  			return -EPERM;
> -		vm_flags |= VM_LOCKED;
> -	}
>  
>  	/* mlock MCL_FUTURE? */
>  	if (vm_flags & VM_LOCKED) {
> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
