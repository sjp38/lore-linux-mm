Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5022B6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 16:43:58 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gm9so5014899lab.12
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:43:57 -0800 (PST)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com. [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id z4si4032203lae.103.2015.01.13.13.43.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 13:43:57 -0800 (PST)
Received: by mail-lb0-f182.google.com with SMTP id u10so4854940lbd.13
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:43:57 -0800 (PST)
Date: Wed, 14 Jan 2015 00:43:55 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/2] mm: rename mm->nr_ptes to mm->nr_pgtables
Message-ID: <20150113214355.GC2253@moon>
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org

On Tue, Jan 13, 2015 at 09:14:15PM +0200, Kirill A. Shutemov wrote:
> We're going to account pmd page tables too. Let's rename mm->nr_pgtables
> to something more generic.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -64,7 +64,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		data << (PAGE_SHIFT-10),
>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
>  		(PTRS_PER_PTE * sizeof(pte_t) *
> -		 atomic_long_read(&mm->nr_ptes)) >> 10,
> +		 atomic_long_read(&mm->nr_pgtables)) >> 10,

This implies that (PTRS_PER_PTE * sizeof(pte_t)) = (PTRS_PER_PMD * sizeof(pmd_t))
which might be true for all archs, right?

Other looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
