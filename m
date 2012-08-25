Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 88F416B002B
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 08:36:38 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so3741138vcb.14
        for <linux-mm@kvack.org>; Sat, 25 Aug 2012 05:36:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120823171854.473831303@de.ibm.com>
References: <20120823171733.595087166@de.ibm.com>
	<20120823171854.473831303@de.ibm.com>
Date: Sat, 25 Aug 2012 20:36:37 +0800
Message-ID: <CAJd=RBBQJCxgdrEnAdoVu+PLjkzTOBnDyJX_bqUdbQdo5TQoJw@mail.gmail.com>
Subject: Re: [RFC patch 2/7] thp: introduce pmdp_invalidate()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com, linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Fri, Aug 24, 2012 at 1:17 AM, Gerald Schaefer
<gerald.schaefer@de.ibm.com> wrote:

> +#ifndef __HAVE_ARCH_PMDP_INVALIDATE
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline void pmdp_invalidate(struct vm_area_struct *vma,
> +                                  unsigned long address, pmd_t *pmdp)
> +{
> +       set_pmd_at(vma->vm_mm, address, pmd, pmd_mknotpresent(*pmd));

	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(*pmdp));  yes?

> +       flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
