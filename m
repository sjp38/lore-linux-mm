Date: Fri, 2 Nov 2007 13:28:46 -0500
From: Matt Mackall <mpm@selenic.com>
Message-ID: <20071102182846.GO19691@waste.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Adrian Bunk <bunk@stusta.de>, Hugh@waste.org
List-ID: <linux-mm.kvack.org>

Dickins <hugh@veritas.com>
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Bcc: 
Subject: Re: [PATCH] Remove unused code from mm/tiny-shmem.c
Reply-To: 
In-Reply-To: <20071102172056.14261.39829.sendpatchset@balbir-laptop>

On Fri, Nov 02, 2007 at 10:50:56PM +0530, Balbir Singh wrote:
> This code in mm/tiny-shmem.c is under #if 0, do we really need it? This
> patch removes it.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Adrian added the #ifdefs in March, not sure why he didn't kill it outright.

Acked-by: Matt Mackall <mpm@selenic.com>

>  mm/tiny-shmem.c |   12 ------------
>  1 file changed, 12 deletions(-)
> 
> diff -puN mm/tiny-shmem.c~remove-unused-code mm/tiny-shmem.c
> --- linux-2.6-latest/mm/tiny-shmem.c~remove-unused-code	2007-11-02 22:43:12.000000000 +0530
> +++ linux-2.6-latest-balbir/mm/tiny-shmem.c	2007-11-02 22:43:30.000000000 +0530
> @@ -121,18 +121,6 @@ int shmem_unuse(swp_entry_t entry, struc
>  	return 0;
>  }
>  
> -#if 0
> -int shmem_mmap(struct file *file, struct vm_area_struct *vma)
> -{
> -	file_accessed(file);
> -#ifndef CONFIG_MMU
> -	return ramfs_nommu_mmap(file, vma);
> -#else
> -	return 0;
> -#endif
> -}
> -#endif  /*  0  */
> -
>  #ifndef CONFIG_MMU
>  unsigned long shmem_get_unmapped_area(struct file *file,
>  				      unsigned long addr,

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
