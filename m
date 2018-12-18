Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 94F4B8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 12:23:04 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e68so12398634plb.3
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 09:23:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h5si13697339pgk.249.2018.12.18.09.23.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Dec 2018 09:23:03 -0800 (PST)
Date: Tue, 18 Dec 2018 09:22:36 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V4 5/5] arch/powerpc/mm/hugetlb: NestMMU workaround for
 hugetlb mprotect RW upgrade
Message-ID: <20181218172236.GC22729@infradead.org>
References: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com>
 <20181218094137.13732-6-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218094137.13732-6-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, Dec 18, 2018 at 03:11:37PM +0530, Aneesh Kumar K.V wrote:
> +EXPORT_SYMBOL(huge_ptep_modify_prot_start);

The only user of this function is the one you added in the last patch
in mm/hugetlb.c, so there is no need to export this function.

> +
> +void huge_ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
> +				  pte_t *ptep, pte_t old_pte, pte_t pte)
> +{
> +
> +	if (radix_enabled())
> +		return radix__huge_ptep_modify_prot_commit(vma, addr, ptep,
> +							   old_pte, pte);
> +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
> +}
> +EXPORT_SYMBOL(huge_ptep_modify_prot_commit);

Same here.
