Subject: Re: [RFC PATCH for -mm 2/5] related function comment fixes
	(optional)
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080811160430.945C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080811160430.945C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 15:02:58 -0400
Message-Id: <1218567778.6360.90.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-11 at 16:05 +0900, KOSAKI Motohiro wrote:
> Now, __mlock_vma_pages_range has sevaral wrong comment.
>  - don't write about mlock parameter
>  - write about require write lock, but it is not true.
> 
> following patch fixes it.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> ---
>  mm/mlock.c |   13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> Index: b/mm/mlock.c
> ===================================================================
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -144,11 +144,18 @@ static void munlock_vma_page(struct page
>  }
>  
>  /*
> - * mlock a range of pages in the vma.
> + * mlock/munlock a range of pages in the vma.
>   *
> - * This takes care of making the pages present too.
> + * If @mlock==1, this takes care of making the pages present too.
>   *
> - * vma->vm_mm->mmap_sem must be held for write.
> + * @vma:   target vma
> + * @start: start address
> + * @end:   end address
> + * @mlock: 0 indicate munlock, otherwise mlock.
> + *
> + * return 0 if successed, otherwse return negative value.

How about:

	return 0 on success, [negative] error number on error.

Or something like that.
> + *
> + * vma->vm_mm->mmap_sem must be held for read.
>   */
>  static int __mlock_vma_pages_range(struct vm_area_struct *vma,
>  				   unsigned long start, unsigned long end,
> 
> 

Otherwise,

Acked-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
