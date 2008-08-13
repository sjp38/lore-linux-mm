Date: Tue, 12 Aug 2008 17:14:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 0/2] Memory rlimit fix crash on fork
Message-Id: <20080812171407.2f468729.akpm@linux-foundation.org>
In-Reply-To: <20080811100719.26336.98302.sendpatchset@balbir-laptop>
References: <20080811100719.26336.98302.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 11 Aug 2008 15:37:19 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> --- linux-2.6.27-rc1/mm/memory.c~memrlimit-fix-crash-on-fork	2008-08-11 14:57:48.000000000 +0530
> +++ linux-2.6.27-rc1-balbir/mm/memory.c	2008-08-11 14:58:33.000000000 +0530
> @@ -901,8 +901,12 @@ unsigned long unmap_vmas(struct mmu_gath

^^ returns a long.

>  	unsigned long start = start_addr;
>  	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
>  	int fullmm = (*tlbp)->fullmm;
> -	struct mm_struct *mm = vma->vm_mm;
> +	struct mm_struct *mm;
> +
> +	if (!vma)
> +		return;

^^ mm/memory.c:907: warning: 'return' with no value, in function returning non-void

How does this happen?

I'll drop the patch.  The above mystery change needs a comment, IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
