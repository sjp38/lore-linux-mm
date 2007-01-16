Date: Tue, 16 Jan 2007 10:49:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/29] Page Table Interface Explanation
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.64.0701161048450.30540@schroedinger.engr.sgi.com>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am glad to see that this endeavor is still going forward.

> int copy_dual_iterator(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> 		unsigned long addr, unsigned long end, struct vm_area_struct *vma);
> 
> unsigned long unmap_page_range_iterator(struct mmu_gather *tlb,
>         struct vm_area_struct *vma, unsigned long addr, unsigned long end,
>         long *zap_work, struct zap_details *details);
> 
> int zeromap_build_iterator(struct mm_struct *mm,
> 		unsigned long addr, unsigned long end, pgprot_t prot);
> 
> int remap_build_iterator(struct mm_struct *mm,
> 		unsigned long addr, unsigned long end, unsigned long pfn,
> 		pgprot_t prot);
> 
> void change_protection_read_iterator(struct vm_area_struct *vma,
> 		unsigned long addr, unsigned long end, pgprot_t newprot,
> 		int dirty_accountable);
> 
> void vunmap_read_iterator(unsigned long addr, unsigned long end);
> 
> int vmap_build_iterator(unsigned long addr,
> 		unsigned long end, pgprot_t prot, struct page ***pages);
> 
> int unuse_vma_read_iterator(struct vm_area_struct *vma,
> 		unsigned long addr, unsigned long end, swp_entry_t entry, struct page *page);
> 
> void smaps_read_iterator(struct vm_area_struct *vma,
> 		unsigned long addr, unsigned long end, struct mem_size_stats *mss);
> 
> int check_policy_read_iterator(struct vm_area_struct *vma,
> 		unsigned long addr, unsigned long end, const nodemask_t *nodes,
> 		unsigned long flags, void *private);
> 
> unsigned long move_page_tables(struct vm_area_struct *vma,
> 		unsigned long old_addr, struct vm_area_struct *new_vma,
> 		unsigned long new_addr, unsigned long len);

Why do we need so many individual specialized iterators? Isnt there some 
way to have a common iterator function?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
