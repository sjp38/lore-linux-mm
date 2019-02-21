Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 238DAC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:04:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9B4B2083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:04:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9B4B2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68F5C8E009F; Thu, 21 Feb 2019 13:04:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 640CF8E009E; Thu, 21 Feb 2019 13:04:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 555E08E009F; Thu, 21 Feb 2019 13:04:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B74F8E009E
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:04:35 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 207so5943397qkl.2
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:04:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QpgmNAqOxDdO9kaPEe2YIOkmjkrB1wLkrvg6sNjzyE0=;
        b=JLdsDO1mO/VVBXq2XsM3e/XixFTyL67FUcg0MKkzmvlDYqicZVeSfsO4NxjiWGXFAF
         GQP9UsiB/3UbNrAI8CF4eSeOzpzsdpdtzMfDAHjyHfjGEG8Oe6SFEdPr/9rAlFa/Vukh
         dCkgS3QeZt8rj96tj97d8q4hbS6zNT55pO1U4gxiDUyhsbcTGMr9+2Ct3/8oQlMyP6AQ
         UmfpCpXBcaneb7pVDshPpSjIilbAq+jh4bSbAfH3JW0q1I4lgS33D3xxwOzrIaPyuR7o
         +PhPpHm+tGGB9f4IMc3oBUT76n0yW1SsJktNMc8ZhHbBJ38FKQGpTfbSQdWO2QC8inqA
         cIlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua3hCONVcTT7lGcgvpwUaRZ4GyEE3RaSeipKv2oPDWjU39IRClB
	DtPtqZVRzK0s+90igLeciPFt9usCdNc5vBeNsVnzvtkp+DnO2qUNTlVXTNefaEB+CzVv85exrCx
	R+7xT3NirGqAGNJCw/4b5eJk7ksR0keWF3BcQw6j9tQXajTjHd8wwZP/d/fM6f42eMQ==
X-Received: by 2002:a0c:9e05:: with SMTP id p5mr30365698qve.246.1550772274884;
        Thu, 21 Feb 2019 10:04:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYCBjr4koh0k7DUBQ62caDtaOLmXvdRzV12gYRe4/TGm8H6dPqIKpg4h5yBIDxghJZx0jps
X-Received: by 2002:a0c:9e05:: with SMTP id p5mr30365645qve.246.1550772273968;
        Thu, 21 Feb 2019 10:04:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550772273; cv=none;
        d=google.com; s=arc-20160816;
        b=aR9Jj3kFF2p1b27PiaEUPCa/kzfKg0WsLaI5jomQDKWjXrK8u4y8O7l/nZG4fyX/g/
         ndA00ju32S5ycaWXPmJnVn9QkiJDy03/f7NK6mgMzIJTN8V7laK1F+OmmnLTRRBy79Ln
         wkUTjtCGuBmNBSrpJfvxs9cnd+/bCk+rB9Q5fYhuAijX6BnDAm06+/wRWdHOjfofHoyV
         Fv89KiCVSPzdB9Gu0Q2rX+AkkbLLWa1/eCf5T0hPApnKjtOc+ewoAuqC/UN7VJsRlWmg
         y/OD3RDI6EUFLkNLTr2l38xi4auDnM0jGswdNgzgmaEnL7L+ckqtS280QJDCatVNSKnj
         0LUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QpgmNAqOxDdO9kaPEe2YIOkmjkrB1wLkrvg6sNjzyE0=;
        b=Xxl2xfTMHg25IOz1cjueRK5Ck6zCZ5e/MmAKaetKBot+ExYEVxbyeOAx2+hg3PS7WF
         2PF7n0lVSUcA4Rb2OHmQ2GfKS0fC3E8Xx550VzWgaGEEAAqeiM0wDPr78tqRQHsZUKVP
         0r0Vy5g96QWDwpN0ZncUoOrilcJ/jrKs2RnTUXlIjIwzq0s5AwBsPOMmRh8b9UqrCshL
         EvDKGLa3PhPVSZXsPw1YnK+cLnztUychUSNY7juFHrieqFCswPzDTvMJ05vuvOnHVLdG
         3wQizN/LY86XlVGUe6DDgmNCrTPYQv6Yd/iYIaAEzzYExz68mtUl1eoKmFYaOz3CM7Le
         4CbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f44si1236697qta.142.2019.02.21.10.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:04:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9E921307DAC1;
	Thu, 21 Feb 2019 18:04:32 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 017945C297;
	Thu, 21 Feb 2019 18:04:25 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:04:24 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 14/26] userfaultfd: wp: handle COW properly for uffd-wp
Message-ID: <20190221180423.GN2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-15-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-15-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 21 Feb 2019 18:04:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:20AM +0800, Peter Xu wrote:
> This allows uffd-wp to support write-protected pages for COW.
> 
> For example, the uffd write-protected PTE could also be write-protected
> by other usages like COW or zero pages.  When that happens, we can't
> simply set the write bit in the PTE since otherwise it'll change the
> content of every single reference to the page.  Instead, we should do
> the COW first if necessary, then handle the uffd-wp fault.
> 
> To correctly copy the page, we'll also need to carry over the
> _PAGE_UFFD_WP bit if it was set in the original PTE.
> 
> For huge PMDs, we just simply split the huge PMDs where we want to
> resolve an uffd-wp page fault always.  That matches what we do with
> general huge PMD write protections.  In that way, we resolved the huge
> PMD copy-on-write issue into PTE copy-on-write.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Few comments see below.

> ---
>  mm/memory.c   |  2 ++
>  mm/mprotect.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++---
>  2 files changed, 54 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 32d32b6e6339..b5d67bafae35 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2291,6 +2291,8 @@ vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  		}
>  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>  		entry = mk_pte(new_page, vma->vm_page_prot);
> +		if (pte_uffd_wp(vmf->orig_pte))
> +			entry = pte_mkuffd_wp(entry);
>  		entry = maybe_mkwrite(pte_mkdirty(entry), vma);

This looks wrong to me, isn't the uffd_wp flag clear on writeable pte ?
If so it would be clearer to have something like:

 +		if (pte_uffd_wp(vmf->orig_pte))
 +			entry = pte_mkuffd_wp(entry);
 +		else
 + 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);

>  		/*
>  		 * Clear the pte entry and flush it first, before updating the
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 9d4433044c21..ae93721f3795 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -77,14 +77,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  		if (pte_present(oldpte)) {
>  			pte_t ptent;
>  			bool preserve_write = prot_numa && pte_write(oldpte);
> +			struct page *page;
>  
>  			/*
>  			 * Avoid trapping faults against the zero or KSM
>  			 * pages. See similar comment in change_huge_pmd.
>  			 */
>  			if (prot_numa) {
> -				struct page *page;
> -
>  				page = vm_normal_page(vma, addr, oldpte);
>  				if (!page || PageKsm(page))
>  					continue;
> @@ -114,6 +113,46 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  					continue;
>  			}
>  
> +			/*
> +			 * Detect whether we'll need to COW before
> +			 * resolving an uffd-wp fault.  Note that this
> +			 * includes detection of the zero page (where
> +			 * page==NULL)
> +			 */
> +			if (uffd_wp_resolve) {
> +				/* If the fault is resolved already, skip */
> +				if (!pte_uffd_wp(*pte))
> +					continue;
> +				page = vm_normal_page(vma, addr, oldpte);
> +				if (!page || page_mapcount(page) > 1) {

This is wrong, if you allow page to be NULL then you gonna segfault
in wp_page_copy() down below. Are you sure you want to test for
special page ? For anonymous memory this should never happens ie
anon page always are regular page. So if you allow userfaulfd to
write protect only anonymous vma then there is no point in testing
here beside maybe a BUG_ON() just in case ...

> +					struct vm_fault vmf = {
> +						.vma = vma,
> +						.address = addr & PAGE_MASK,
> +						.page = page,
> +						.orig_pte = oldpte,
> +						.pmd = pmd,
> +						/* pte and ptl not needed */
> +					};
> +					vm_fault_t ret;
> +
> +					if (page)
> +						get_page(page);
> +					arch_leave_lazy_mmu_mode();
> +					pte_unmap_unlock(pte, ptl);
> +					ret = wp_page_copy(&vmf);
> +					/* PTE is changed, or OOM */
> +					if (ret == 0)
> +						/* It's done by others */
> +						continue;
> +					else if (WARN_ON(ret != VM_FAULT_WRITE))
> +						return pages;
> +					pte = pte_offset_map_lock(vma->vm_mm,
> +								  pmd, addr,
> +								  &ptl);

Here you remap the pte locked but you are not checking if the pte is
the one you expect ie is it pointing to the copied page and does it
have expect uffd_wp flag. Another thread might have raced between the
time you called wp_page_copy() and the time you pte_offset_map_lock()
I have not check the mmap_sem so maybe you are protected by it as
mprotect is taking it in write mode IIRC, if so you should add a
comments at very least so people do not see this as a bug.


> +					arch_enter_lazy_mmu_mode();
> +				}
> +			}
> +
>  			ptent = ptep_modify_prot_start(mm, addr, pte);
>  			ptent = pte_modify(ptent, newprot);
>  			if (preserve_write)
> @@ -183,6 +222,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  	unsigned long pages = 0;
>  	unsigned long nr_huge_updates = 0;
>  	struct mmu_notifier_range range;
> +	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
>  
>  	range.start = 0;
>  
> @@ -202,7 +242,16 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		}
>  
>  		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
> -			if (next - addr != HPAGE_PMD_SIZE) {
> +			/*
> +			 * When resolving an userfaultfd write
> +			 * protection fault, it's not easy to identify
> +			 * whether a THP is shared with others and
> +			 * whether we'll need to do copy-on-write, so
> +			 * just split it always for now to simply the
> +			 * procedure.  And that's the policy too for
> +			 * general THP write-protect in af9e4d5f2de2.
> +			 */
> +			if (next - addr != HPAGE_PMD_SIZE || uffd_wp_resolve) {

Using parenthesis maybe ? :)
            if ((next - addr != HPAGE_PMD_SIZE) || uffd_wp_resolve) {

