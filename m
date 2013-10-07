Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3379A6B003A
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 09:21:59 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so7143911pbb.28
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 06:21:58 -0700 (PDT)
Message-ID: <5252B56C.8030903@parallels.com>
Date: Mon, 7 Oct 2013 17:21:48 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] smaps: show VM_SOFTDIRTY flag in VmFlags line
References: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1380913335-17466-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org

On 10/04/2013 11:02 PM, Naoya Horiguchi wrote:
> This flag shows that soft dirty bit is not enabled yet.
> You can enable it by "echo 4 > /proc/pid/clear_refs."

The comment is not correct. Per-VMA soft-dirty flag means, that
VMA is "newly created" one and thus represents a new (dirty) are
in task's VM.

Other than this -- yes, it's nice to have this flag in smaps.

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  fs/proc/task_mmu.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git v3.12-rc2-mmots-2013-09-24-17-03.orig/fs/proc/task_mmu.c v3.12-rc2-mmots-2013-09-24-17-03/fs/proc/task_mmu.c
> index 7366e9d..c591928 100644
> --- v3.12-rc2-mmots-2013-09-24-17-03.orig/fs/proc/task_mmu.c
> +++ v3.12-rc2-mmots-2013-09-24-17-03/fs/proc/task_mmu.c
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
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
