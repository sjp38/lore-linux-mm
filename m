Date: Mon, 19 Feb 2007 11:48:16 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated helper macros.
Message-ID: <20070219194816.GM21484@holomorphy.com>
References: <20070219183123.27318.27319.stgit@localhost.localdomain> <20070219183133.27318.92920.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070219183133.27318.92920.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 19, 2007 at 10:31:34AM -0800, Adam Litke wrote:
> +struct pagetable_operations_struct {
> +	int (*fault)(struct mm_struct *mm,
> +		struct vm_area_struct *vma,
> +		unsigned long address, int write_access);
> +	int (*copy_vma)(struct mm_struct *dst, struct mm_struct *src,
> +		struct vm_area_struct *vma);
> +	int (*pin_pages)(struct mm_struct *mm, struct vm_area_struct *vma,
> +		struct page **pages, struct vm_area_struct **vmas,
> +		unsigned long *position, int *length, int i);
> +	void (*change_protection)(struct vm_area_struct *vma,
> +		unsigned long address, unsigned long end, pgprot_t newprot);
> +	unsigned long (*unmap_page_range)(struct vm_area_struct *vma,
> +		unsigned long address, unsigned long end, long *zap_work);
> +	void (*free_pgtable_range)(struct mmu_gather **tlb,
> +		unsigned long addr, unsigned long end,
> +		unsigned long floor, unsigned long ceiling);
> +};

I very very strongly approve of the approach this operations structure
entails.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
