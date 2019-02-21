Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47621C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 02:48:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5C702086D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 02:48:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UGedkK89"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5C702086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71E218E0058; Wed, 20 Feb 2019 21:48:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CC318E0002; Wed, 20 Feb 2019 21:48:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3958E0058; Wed, 20 Feb 2019 21:48:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA79D8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 21:48:47 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id y20so732894lfy.20
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 18:48:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dxwBobXFD+9+VXoptpQ1b8TWS6kRbQlZe88PHQFOGuE=;
        b=qMJBxIl0CTY8xRlzsJ7gSkdzo4vphtf4mRZSIKMlfTkWfSoDx2bxzAGsSwl9gVeAZg
         dk3Ym+J17q7rsYMYYlcKwM6YXzsnf8nzrYhcbnmVBBoa7sTL5pnBPuOHqMrtDCjIUQgY
         uB8d8P/vmyUVwu6AcQzIhnOpT4Ja+xQBDL2N01LHFPFj7P+VgAxsjJu0QRyRNmrNus2B
         a7eGosDikQw8deu0bAVZ3o5P9phkDlYd2kHrci06mp6pQQpwMven5S9el02M9GSfWwfM
         HFbBXi7RR8Q1nzIdF7RWmKkOcYmaDct7Ld98xFHovWN1dyuup2jSsKRJo6IRVVSeIX60
         CSIQ==
X-Gm-Message-State: AHQUAuZ6TbYDjHLqjBpRZpnIQu+YoT5ohjJtenTXxULG77d/tKhcltR9
	GX4oe8JhymMlsSxbL68XNl9BcfPBIrzUK/qVN29ghfCGx4rHuNkajWUy/cMzm26mE9BRbWTgpHZ
	W/NwXAT5P0+GGNB5Nx1gA7dXRQQd/R+8yjTnn5Din1THiFMqOridGLhwHHD7NdydPyhhGi8xwHW
	kZKzGQ4YXRr+klGTNvZvPJxE0SWxFMmznbP0+xJEcs52kAuFb36KKC8y4G8roBSzcj302jPVU8a
	xFSWFQM45kYdNkZN63PtPGOmLuYJcohpK3UCx87JQvk7fChNgKLjW2R1Nig93p6qw0ySeeB1y8W
	5DpwoS1KOcR2yk6KJAgpBuF8OI1rBLCXI2SoEwQNS/MhLfkwAvgxizcMgoh42ax07yeeFt5dEK2
	W
X-Received: by 2002:a2e:9001:: with SMTP id h1mr22508918ljg.5.1550717327023;
        Wed, 20 Feb 2019 18:48:47 -0800 (PST)
X-Received: by 2002:a2e:9001:: with SMTP id h1mr22508880ljg.5.1550717325769;
        Wed, 20 Feb 2019 18:48:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550717325; cv=none;
        d=google.com; s=arc-20160816;
        b=y1hFdQNmweqffNXGvMiczDuKQTzlDrJznIe58v0DdTo0eY0zLQS4MGUo6ULRnL44Zr
         dpBttf9KAbANF8q3vdpqxfarBVCDqhgmCkhwfxQA9h3fa6eEQpdDBCdOFytU8qErXsib
         4gYwu/J0LCg52akroh5X6oQKa9l81GETJ1xLbUk1AEqlrbS1K4UZ4KH0YeSe4NcMIPVB
         3Hs9DW9XKp8jWfYHcOyi5gTc/F/xGPyApuVyWY2y4JLtwqqh3fUZ11mSK2+6+6tuqDF9
         k+h+v9F9UfND6fVA5a6x4gnkwvA90GWsIVLGFu+TttzJxaR8YW89dNAN+GWMQcT+g+AJ
         hm2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dxwBobXFD+9+VXoptpQ1b8TWS6kRbQlZe88PHQFOGuE=;
        b=t/S6L3kiRHaVwvb3mhfYxVvKm7/aaNwk5TrZ9RqhPS0zTsxnbGVBpoc7OwNoHY/IwH
         SCtUASmFDp4p9AWwh8csI8ifkgxEP80hyFJCyoX0q2KYNOckl7No0zIkF0hxQC8wQ/12
         M6Sc0D/svqY89gsmV4bkUu4CHDEeamX01l10eikFuSguzzx5hVEsyVRTOFYGKS4SfKTa
         mVPZKXgQjOEdGxx/wVtwPUONH+hN8igjg7nCI3lfOJdJFxOCAht6rXnYmaKyGZEUtJxd
         5RrNAW5Kvzxj0qy3pMf+NQOwUBJf/PpIrMxk5bSXsfLy56UVzTkBqV1xRIr+KjvMUoHH
         kXjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UGedkK89;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor3231525lfh.50.2019.02.20.18.48.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 18:48:45 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UGedkK89;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dxwBobXFD+9+VXoptpQ1b8TWS6kRbQlZe88PHQFOGuE=;
        b=UGedkK89K+pPgRYRy+xWu1A2irXkJUD47zDO+UZCh3x7gq852b8BYfsfjJen/Nwi8R
         1kQzHGQF6nfCKpV2iUA5G7rlhPgJ1TZckXrV2OB85LGFZ6kPzse8SC9Ws6rSj0LgkRET
         M5m01+j+nBZGX7hpqJSvrjXxVzbA07zJ65D9E3jqSmR3arI8sTfHD+Ob0FoY1QFjvTzb
         BE99JnP1+Kvr3FJ+J1tVeipPrysbj4BXgO7KnQd7uv0PU8OnnRhwqc9974GsgANBjApw
         KYsQXoJ2QFcwYM/kVaD5HWv0cXX0/odRuKhAEgzH3FglZ7hT20DWYYSwnKokXgB/K8X6
         bJag==
X-Google-Smtp-Source: AHgI3IbbduPfsbneQ4f6edh3FcdSzcodv7Cu/R0HXeLJWA+i2/COEQTTMxZxEDQytlzhYRE8XsNXMywZWfiFnNaUDhA=
X-Received: by 2002:ac2:5496:: with SMTP id t22mr22466682lfk.31.1550717325067;
 Wed, 20 Feb 2019 18:48:45 -0800 (PST)
MIME-Version: 1.0
References: <20190219103148.192029670@infradead.org> <20190219103233.383087152@infradead.org>
In-Reply-To: <20190219103233.383087152@infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 21 Feb 2019 08:22:57 +0530
Message-ID: <CAFqt6zZK_qUjdqKXW9PchjLkPvcsD_WPNFZJ8sBjz-+QXR4jFw@mail.gmail.com>
Subject: Re: [PATCH v6 09/18] ia64/tlb: Conver to generic mmu_gather
To: Peter Zijlstra <peterz@infradead.org>
Cc: will.deacon@arm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, npiggin@gmail.com, linux-arch@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, heiko.carstens@de.ibm.com, 
	Rik van Riel <riel@surriel.com>, Tony Luck <tony.luck@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 4:03 PM Peter Zijlstra <peterz@infradead.org> wrote:
>
> Generic mmu_gather provides everything ia64 needs (range tracking).
>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Nick Piggin <npiggin@gmail.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  arch/ia64/include/asm/tlb.h      |  256 ---------------------------------------
>  arch/ia64/include/asm/tlbflush.h |   25 +++
>  arch/ia64/mm/tlb.c               |   23 +++
>  3 files changed, 47 insertions(+), 257 deletions(-)
>
> --- a/arch/ia64/include/asm/tlb.h
> +++ b/arch/ia64/include/asm/tlb.h
> @@ -47,262 +47,8 @@
>  #include <asm/tlbflush.h>
>  #include <asm/machvec.h>
>
> -/*
> - * If we can't allocate a page to make a big batch of page pointers
> - * to work on, then just handle a few from the on-stack structure.
> - */
> -#define        IA64_GATHER_BUNDLE      8
> -
> -struct mmu_gather {
> -       struct mm_struct        *mm;
> -       unsigned int            nr;
> -       unsigned int            max;
> -       unsigned char           fullmm;         /* non-zero means full mm flush */
> -       unsigned char           need_flush;     /* really unmapped some PTEs? */
> -       unsigned long           start, end;
> -       unsigned long           start_addr;
> -       unsigned long           end_addr;
> -       struct page             **pages;
> -       struct page             *local[IA64_GATHER_BUNDLE];
> -};
> -
> -struct ia64_tr_entry {
> -       u64 ifa;
> -       u64 itir;
> -       u64 pte;
> -       u64 rr;
> -}; /*Record for tr entry!*/
> -
> -extern int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size);
> -extern void ia64_ptr_entry(u64 target_mask, int slot);
> -
> -extern struct ia64_tr_entry *ia64_idtrs[NR_CPUS];
> -
> -/*
> - region register macros
> -*/
> -#define RR_TO_VE(val)   (((val) >> 0) & 0x0000000000000001)
> -#define RR_VE(val)     (((val) & 0x0000000000000001) << 0)
> -#define RR_VE_MASK     0x0000000000000001L
> -#define RR_VE_SHIFT    0
> -#define RR_TO_PS(val)  (((val) >> 2) & 0x000000000000003f)
> -#define RR_PS(val)     (((val) & 0x000000000000003f) << 2)
> -#define RR_PS_MASK     0x00000000000000fcL
> -#define RR_PS_SHIFT    2
> -#define RR_RID_MASK    0x00000000ffffff00L
> -#define RR_TO_RID(val)         ((val >> 8) & 0xffffff)
> -
> -static inline void
> -ia64_tlb_flush_mmu_tlbonly(struct mmu_gather *tlb, unsigned long start, unsigned long end)
> -{
> -       tlb->need_flush = 0;
> -
> -       if (tlb->fullmm) {
> -               /*
> -                * Tearing down the entire address space.  This happens both as a result
> -                * of exit() and execve().  The latter case necessitates the call to
> -                * flush_tlb_mm() here.
> -                */
> -               flush_tlb_mm(tlb->mm);
> -       } else if (unlikely (end - start >= 1024*1024*1024*1024UL
> -                            || REGION_NUMBER(start) != REGION_NUMBER(end - 1)))
> -       {
> -               /*
> -                * If we flush more than a tera-byte or across regions, we're probably
> -                * better off just flushing the entire TLB(s).  This should be very rare
> -                * and is not worth optimizing for.
> -                */
> -               flush_tlb_all();
> -       } else {
> -               /*
> -                * flush_tlb_range() takes a vma instead of a mm pointer because
> -                * some architectures want the vm_flags for ITLB/DTLB flush.
> -                */
> -               struct vm_area_struct vma = TLB_FLUSH_VMA(tlb->mm, 0);
> -
> -               /* flush the address range from the tlb: */
> -               flush_tlb_range(&vma, start, end);
> -               /* now flush the virt. page-table area mapping the address range: */
> -               flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
> -       }
> -
> -}
> -
> -static inline void
> -ia64_tlb_flush_mmu_free(struct mmu_gather *tlb)
> -{
> -       unsigned long i;
> -       unsigned int nr;
> -
> -       /* lastly, release the freed pages */
> -       nr = tlb->nr;
> -
> -       tlb->nr = 0;
> -       tlb->start_addr = ~0UL;
> -       for (i = 0; i < nr; ++i)
> -               free_page_and_swap_cache(tlb->pages[i]);
> -}
> -
> -/*
> - * Flush the TLB for address range START to END and, if not in fast mode, release the
> - * freed pages that where gathered up to this point.
> - */
> -static inline void
> -ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
> -{
> -       if (!tlb->need_flush)
> -               return;
> -       ia64_tlb_flush_mmu_tlbonly(tlb, start, end);
> -       ia64_tlb_flush_mmu_free(tlb);
> -}
> -
> -static inline void __tlb_alloc_page(struct mmu_gather *tlb)
> -{
> -       unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
> -
> -       if (addr) {
> -               tlb->pages = (void *)addr;
> -               tlb->max = PAGE_SIZE / sizeof(void *);
> -       }
> -}
> -
> -
> -static inline void
> -arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
> -                       unsigned long start, unsigned long end)
> -{
> -       tlb->mm = mm;
> -       tlb->max = ARRAY_SIZE(tlb->local);
> -       tlb->pages = tlb->local;
> -       tlb->nr = 0;
> -       tlb->fullmm = !(start | (end+1));
> -       tlb->start = start;
> -       tlb->end = end;
> -       tlb->start_addr = ~0UL;
> -}
> -
> -/*
> - * Called at the end of the shootdown operation to free up any resources that were
> - * collected.
> - */
> -static inline void
> -arch_tlb_finish_mmu(struct mmu_gather *tlb,
> -                       unsigned long start, unsigned long end, bool force)
> -{
> -       if (force)
> -               tlb->need_flush = 1;
> -       /*
> -        * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
> -        * tlb->end_addr.
> -        */
> -       ia64_tlb_flush_mmu(tlb, start, end);
> -
> -       /* keep the page table cache within bounds */
> -       check_pgt_cache();
> -
> -       if (tlb->pages != tlb->local)
> -               free_pages((unsigned long)tlb->pages, 0);
> -}
> -
> -/*
> - * Logically, this routine frees PAGE.  On MP machines, the actual freeing of the page
> - * must be delayed until after the TLB has been flushed (see comments at the beginning of
> - * this file).
> - */
> -static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
> -{
> -       tlb->need_flush = 1;
> -
> -       if (!tlb->nr && tlb->pages == tlb->local)
> -               __tlb_alloc_page(tlb);
> -
> -       tlb->pages[tlb->nr++] = page;
> -       VM_WARN_ON(tlb->nr > tlb->max);
> -       if (tlb->nr == tlb->max)
> -               return true;
> -       return false;
> -}
> -
> -static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
> -{
> -       ia64_tlb_flush_mmu_tlbonly(tlb, tlb->start_addr, tlb->end_addr);
> -}
> -
> -static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
> -{
> -       ia64_tlb_flush_mmu_free(tlb);
> -}
> -
> -static inline void tlb_flush_mmu(struct mmu_gather *tlb)
> -{
> -       ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
> -}
> -
> -static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
> -{
> -       if (__tlb_remove_page(tlb, page))
> -               tlb_flush_mmu(tlb);
> -}
> -
> -static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
> -                                         struct page *page, int page_size)
> -{
> -       return __tlb_remove_page(tlb, page);
> -}
> -
> -static inline void tlb_remove_page_size(struct mmu_gather *tlb,
> -                                       struct page *page, int page_size)
> -{
> -       return tlb_remove_page(tlb, page);
> -}
> -
> -/*
> - * Remove TLB entry for PTE mapped at virtual address ADDRESS.  This is called for any
> - * PTE, not just those pointing to (normal) physical memory.
> - */
> -static inline void
> -__tlb_remove_tlb_entry (struct mmu_gather *tlb, pte_t *ptep, unsigned long address)
> -{
> -       if (tlb->start_addr == ~0UL)
> -               tlb->start_addr = address;
> -       tlb->end_addr = address + PAGE_SIZE;
> -}
> -
>  #define tlb_migrate_finish(mm) platform_tlb_migrate_finish(mm)
>
> -#define tlb_start_vma(tlb, vma)                        do { } while (0)
> -#define tlb_end_vma(tlb, vma)                  do { } while (0)
> -
> -#define tlb_remove_tlb_entry(tlb, ptep, addr)          \
> -do {                                                   \
> -       tlb->need_flush = 1;                            \
> -       __tlb_remove_tlb_entry(tlb, ptep, addr);        \
> -} while (0)
> -
> -#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)       \
> -       tlb_remove_tlb_entry(tlb, ptep, address)
> -
> -static inline void tlb_change_page_size(struct mmu_gather *tlb,
> -                                                    unsigned int page_size)
> -{
> -}
> -
> -#define pte_free_tlb(tlb, ptep, address)               \
> -do {                                                   \
> -       tlb->need_flush = 1;                            \
> -       __pte_free_tlb(tlb, ptep, address);             \
> -} while (0)
> -
> -#define pmd_free_tlb(tlb, ptep, address)               \
> -do {                                                   \
> -       tlb->need_flush = 1;                            \
> -       __pmd_free_tlb(tlb, ptep, address);             \
> -} while (0)
> -
> -#define pud_free_tlb(tlb, pudp, address)               \
> -do {                                                   \
> -       tlb->need_flush = 1;                            \
> -       __pud_free_tlb(tlb, pudp, address);             \
> -} while (0)
> +#include <asm-generic/tlb.h>
>
>  #endif /* _ASM_IA64_TLB_H */
> --- a/arch/ia64/include/asm/tlbflush.h
> +++ b/arch/ia64/include/asm/tlbflush.h
> @@ -14,6 +14,31 @@
>  #include <asm/mmu_context.h>
>  #include <asm/page.h>
>
> +struct ia64_tr_entry {
> +       u64 ifa;
> +       u64 itir;
> +       u64 pte;
> +       u64 rr;
> +}; /*Record for tr entry!*/
> +
> +extern int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size);
> +extern void ia64_ptr_entry(u64 target_mask, int slot);
> +extern struct ia64_tr_entry *ia64_idtrs[NR_CPUS];
> +
> +/*
> + region register macros
> +*/
> +#define RR_TO_VE(val)   (((val) >> 0) & 0x0000000000000001)
> +#define RR_VE(val)     (((val) & 0x0000000000000001) << 0)
> +#define RR_VE_MASK     0x0000000000000001L
> +#define RR_VE_SHIFT    0
> +#define RR_TO_PS(val)  (((val) >> 2) & 0x000000000000003f)
> +#define RR_PS(val)     (((val) & 0x000000000000003f) << 2)
> +#define RR_PS_MASK     0x00000000000000fcL
> +#define RR_PS_SHIFT    2
> +#define RR_RID_MASK    0x00000000ffffff00L
> +#define RR_TO_RID(val)         ((val >> 8) & 0xffffff)
> +
>  /*
>   * Now for some TLB flushing routines.  This is the kind of stuff that
>   * can be very expensive, so try to avoid them whenever possible.
> --- a/arch/ia64/mm/tlb.c
> +++ b/arch/ia64/mm/tlb.c
> @@ -297,8 +297,8 @@ local_flush_tlb_all (void)
>         ia64_srlz_i();                  /* srlz.i implies srlz.d */
>  }
>
> -void
> -flush_tlb_range (struct vm_area_struct *vma, unsigned long start,
> +static void
> +__flush_tlb_range (struct vm_area_struct *vma, unsigned long start,
>                  unsigned long end)
>  {
>         struct mm_struct *mm = vma->vm_mm;
> @@ -335,6 +335,25 @@ flush_tlb_range (struct vm_area_struct *
>         preempt_enable();
>         ia64_srlz_i();                  /* srlz.i implies srlz.d */
>  }
> +
> +void flush_tlb_range(struct vm_area_struct *vma,
> +               unsigned long start, unsigned long end)
> +{
> +       if (unlikely(end - start >= 1024*1024*1024*1024UL
> +                       || REGION_NUMBER(start) != REGION_NUMBER(end - 1))) {
> +               /*
> +                * If we flush more than a tera-byte or across regions, we're
> +                * probably better off just flushing the entire TLB(s).  This
> +                * should be very rare and is not worth optimizing for.
> +                */
> +               flush_tlb_all();
> +       } else {
> +               /* flush the address range from the tlb */
> +               __flush_tlb_range(vma, start, end);
> +               /* flush the virt. page-table area mapping the addr range */
> +               __flush_tlb_range(vma, ia64_thash(start), ia64_thash(end));
> +       }
> +}
>  EXPORT_SYMBOL(flush_tlb_range);
Just a minor one,
As this is a public API, I think adding docs might be helpful.

