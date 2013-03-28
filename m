Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 3FA896B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 13:03:22 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id ec20so17806866lab.23
        for <linux-mm@kvack.org>; Thu, 28 Mar 2013 10:03:20 -0700 (PDT)
Message-ID: <515477D4.1060206@openvz.org>
Date: Thu, 28 Mar 2013 21:03:16 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] hugetlbfs: stop setting VM_DONTDUMP in initializing
 vma(VM_HUGETLB)
References: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1364485358-8745-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1364485358-8745-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Naoya Horiguchi wrote:
> Currently we fail to include any data on hugepages into coredump,
> because VM_DONTDUMP is set on hugetlbfs's vma. This behavior was recently
> introduced by commit 314e51b98 "mm: kill vma flag VM_RESERVED and
> mm->reserved_vm counter". This looks to me a serious regression,
> so let's fix it.

That was introduced in my patch? Really?
Here was VM_RESERVED and it had the same effect as VM_DONTDUMP. At least I thought so.

>
> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> Cc: Konstantin Khlebnikov<khlebnikov@openvz.org>
> ---
>   fs/hugetlbfs/inode.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git v3.9-rc3.orig/fs/hugetlbfs/inode.c v3.9-rc3/fs/hugetlbfs/inode.c
> index 84e3d85..523464e 100644
> --- v3.9-rc3.orig/fs/hugetlbfs/inode.c
> +++ v3.9-rc3/fs/hugetlbfs/inode.c
> @@ -110,7 +110,7 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>   	 * way when do_mmap_pgoff unwinds (may be important on powerpc
>   	 * and ia64).
>   	 */
> -	vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND | VM_DONTDUMP;
> +	vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND;
>   	vma->vm_ops =&hugetlb_vm_ops;
>
>   	if (vma->vm_pgoff&  (~huge_page_mask(h)>>  PAGE_SHIFT))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
