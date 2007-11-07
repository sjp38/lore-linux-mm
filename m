Date: Wed, 7 Nov 2007 17:30:25 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Use VM_ flags in protection_map rather than magic value
In-Reply-To: <1194387069.18598.92.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0711071727270.15190@blonde.wat.veritas.com>
References: <1194387069.18598.92.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Trivial <trivial@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007, Matt Helsley wrote:
> Replace the magic value with a mask of flags that produce the same
> value. This is consistent with the other uses of protection_map[].
> 
> Signed-off-by: Matt Helsley <matthltc@us.ibm.com>

Thanks, but this comes just a little too late: see 2.6.24-rc1 or -rc2.
Hugh

> ---
>  mm/mmap.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.23/mm/mmap.c
> ===================================================================
> --- linux-2.6.23.orig/mm/mmap.c
> +++ linux-2.6.23/mm/mmap.c
> @@ -2245,11 +2245,12 @@ int install_special_mapping(struct mm_st
>  	vma->vm_mm = mm;
>  	vma->vm_start = addr;
>  	vma->vm_end = addr + len;
>  
>  	vma->vm_flags = vm_flags | mm->def_flags;
> -	vma->vm_page_prot = protection_map[vma->vm_flags & 7];
> +	vma->vm_page_prot = protection_map[vma->vm_flags &
> +						(VM_READ|VM_WRITE|VM_EXEC)];
>  
>  	vma->vm_ops = &special_mapping_vmops;
>  	vma->vm_private_data = pages;
>  
>  	if (unlikely(insert_vm_struct(mm, vma))) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
