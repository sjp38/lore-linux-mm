Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 72E6A6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 21:22:28 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so17564850pad.36
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 18:22:28 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id pp3si19209454pbb.349.2014.02.18.18.22.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 18:22:27 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so17562018pab.2
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 18:22:25 -0800 (PST)
Date: Tue, 18 Feb 2014 18:22:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm 2/3] mm,numa: reorganize change_pmd_range
In-Reply-To: <1392761566-24834-3-git-send-email-riel@redhat.com>
Message-ID: <alpine.DEB.2.02.1402181822010.20791@chino.kir.corp.google.com>
References: <1392761566-24834-1-git-send-email-riel@redhat.com> <1392761566-24834-3-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, chegu_vinod@hp.com, aarcange@redhat.com, akpm@linux-foundation.org

On Tue, 18 Feb 2014, riel@redhat.com wrote:

> From: Rik van Riel <riel@redhat.com>
> 
> Reorganize the order of ifs in change_pmd_range a little, in
> preparation for the next patch.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Xing Gang <gang.xing@hp.com>
> Tested-by: Chegu Vinod <chegu_vinod@hp.com>

Acked-by: David Rientjes <rientjes@google.com>

> ---
>  mm/mprotect.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 769a67a..6006c05 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -118,6 +118,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		unsigned long this_pages;
>  
>  		next = pmd_addr_end(addr, end);
> +		if (!pmd_trans_huge(*pmd) && pmd_none_or_clear_bad(pmd))
> +				continue;
>  		if (pmd_trans_huge(*pmd)) {
>  			if (next - addr != HPAGE_PMD_SIZE)
>  				split_huge_page_pmd(vma, addr, pmd);

Extra tab there, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
