Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D072A5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:03:38 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id n37K3cGX031977
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 21:03:38 +0100
Received: from wf-out-1314.google.com (wfd26.prod.google.com [10.142.4.26])
	by wpaz5.hot.corp.google.com with ESMTP id n37K2V4p013001
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 13:03:36 -0700
Received: by wf-out-1314.google.com with SMTP id 26so3161519wfd.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2009 13:03:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090407072133.053995305@intel.com>
References: <20090407071729.233579162@intel.com>
	 <20090407072133.053995305@intel.com>
Date: Tue, 7 Apr 2009 13:03:36 -0700
Message-ID: <604427e00904071303g1d092eabp59fca0713ddacf82@mail.gmail.com>
Subject: Re: [PATCH 03/14] mm: remove FAULT_FLAG_RETRY dead code
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 7, 2009 at 12:17 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> Cc: Ying Han <yinghan@google.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/memory.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> --- mm.orig/mm/memory.c
> +++ mm/mm/memory.c
> @@ -2766,10 +2766,8 @@ static int do_linear_fault(struct mm_str
>  {
>        pgoff_t pgoff = (((address & PAGE_MASK)
>                        - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> -       int write = write_access & ~FAULT_FLAG_RETRY;
> -       unsigned int flags = (write ? FAULT_FLAG_WRITE : 0);
> +       unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
>
> -       flags |= (write_access & FAULT_FLAG_RETRY);
>        pte_unmap(page_table);
>        return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
>  }
So, we got rid of FAULT_FLAG_RETRY flag?
> --
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
