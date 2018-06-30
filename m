Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B4C526B0006
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 22:25:06 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id z5-v6so6019021pln.20
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 19:25:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b20-v6si9289272pgb.645.2018.06.29.19.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 19:25:05 -0700 (PDT)
Date: Fri, 29 Jun 2018 19:25:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: thp: passing correct vm_flags to hugepage_vma_check
Message-Id: <20180629192503.b41ce9e68d5c267595677a0d@linux-foundation.org>
In-Reply-To: <20180629181752.792831-1-songliubraving@fb.com>
References: <20180629181752.792831-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, Yang Shi <yang.shi@linux.alibaba.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>

On Fri, 29 Jun 2018 11:17:52 -0700 Song Liu <songliubraving@fb.com> wrote:

> Back in May, I sent patch similar to 02b75dc8160d:
> 
> https://patchwork.kernel.org/patch/10416233/  (v1)
> 
> This patch got positive feedback. However, I realized there is a problem,
> that vma->vm_flags in khugepaged_enter_vma_merge() is stale. The separate
> argument vm_flags contains the latest value. Therefore, it is
> necessary to pass this vm_flags into hugepage_vma_check(). To fix this
> problem,  I resent v2 and v3 of the work:
> 
> https://patchwork.kernel.org/patch/10419527/   (v2)
> https://patchwork.kernel.org/patch/10433937/   (v3)
> 
> To my surprise, after I thought we all agreed on v3 of the work. Yang's
> patch, which is similar to correct looking (but wrong) v1, got applied.
> So we still have the issue of stale vma->vm_flags. This patch fixes this
> issue. Please apply.

That's a ueful history lesson but most of it isn't relevant to this
change.  So I'd suggest this changelog:

: khugepaged_enter_vma_merge() passes a stale vma->vm_flags to
: hugepage_vma_check().  The argument vm_flags contains the latest value. 
: Therefore, it is necessary to pass this vm_flags into
: hugepage_vma_check().

Also, please (as always) tell us the user-visible runtime effects of
this bug so that others can decide which kernel(s) need the fix?
