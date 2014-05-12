Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 57D4D6B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 13:05:15 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so4846088eek.16
        for <linux-mm@kvack.org>; Mon, 12 May 2014 10:05:14 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id d1si6240195eem.25.2014.05.12.10.05.13
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 10:05:13 -0700 (PDT)
Date: Mon, 12 May 2014 20:05:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: remap_file_pages: initialize populate before usage
Message-ID: <20140512170504.GA30120@node.dhcp.inet.fi>
References: <1399898454-14915-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399898454-14915-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 12, 2014 at 08:40:54AM -0400, Sasha Levin wrote:
> 'populate' wasn't initialized before being used in error paths,
> causing panics when mm_populate() would get called with invalid
> values.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
>  mm/mmap.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 84dcfc7..2a0e0a8 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2591,7 +2591,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
>  
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma;
> -	unsigned long populate;
> +	unsigned long populate = 0;
>  	unsigned long ret = -EINVAL;
>  
>  	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. "
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
