Date: Mon, 22 Sep 2008 01:30:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in
 /proc/pid/smaps
Message-Id: <20080922013053.39fd367a.akpm@linux-foundation.org>
In-Reply-To: <1222047492-27622-2-git-send-email-mel@csn.ul.ie>
References: <1222047492-27622-1-git-send-email-mel@csn.ul.ie>
	<1222047492-27622-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Sep 2008 02:38:11 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> +		   vma_page_size(vma) >> 10);
>  
>  	return ret;
>  }
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 32e0ef0..0c83445 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -231,6 +231,19 @@ static inline unsigned long huge_page_size(struct hstate *h)
>  	return (unsigned long)PAGE_SIZE << h->order;
>  }
>  
> +static inline unsigned long vma_page_size(struct vm_area_struct *vma)
> +{
> +	struct hstate *hstate;
> +
> +	if (!is_vm_hugetlb_page(vma))
> +		return PAGE_SIZE;
> +
> +	hstate = hstate_vma(vma);
> +	VM_BUG_ON(!hstate);
> +
> +	return 1UL << (hstate->order + PAGE_SHIFT);
> +}
> +

CONFIG_HUGETLB_PAGE=n?

What did you hope to gain by inlining this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
