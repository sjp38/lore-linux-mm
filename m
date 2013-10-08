Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 963436B003A
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 20:51:29 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so8165678pab.29
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 17:51:29 -0700 (PDT)
Date: Mon, 7 Oct 2013 17:51:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2 v2] smaps: show VM_SOFTDIRTY flag in VmFlags line
Message-Id: <20131007175125.7bb300853d37b6a64eba248d@linux-foundation.org>
In-Reply-To: <1381155304-2ro6e10t-mutt-n-horiguchi@ah.jp.nec.com>
References: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<5252B56C.8030903@parallels.com>
	<1381155304-2ro6e10t-mutt-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org

On Mon, 07 Oct 2013 10:15:04 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Fri, 4 Oct 2013 13:42:13 -0400
> Subject: [PATCH] smaps: show VM_SOFTDIRTY flag in VmFlags line
> 
> This flag shows that the VMA is "newly created" and thus represents
> "dirty" in the task's VM.
> You can clear it by "echo 4 > /proc/pid/clear_refs."
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  fs/proc/task_mmu.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 7366e9d..c591928 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -561,6 +561,9 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
>  		[ilog2(VM_NONLINEAR)]	= "nl",
>  		[ilog2(VM_ARCH_1)]	= "ar",
>  		[ilog2(VM_DONTDUMP)]	= "dd",
> +#ifdef CONFIG_MEM_SOFT_DIRTY
> +		[ilog2(VM_SOFTDIRTY)]	= "sd",
> +#endif
>  		[ilog2(VM_MIXEDMAP)]	= "mm",
>  		[ilog2(VM_HUGEPAGE)]	= "hg",
>  		[ilog2(VM_NOHUGEPAGE)]	= "nh",

Documentation/filesystems/proc.txt needs updating, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
