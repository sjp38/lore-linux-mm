Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1B56B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 15:41:50 -0400 (EDT)
Received: by iebmp1 with SMTP id mp1so871435ieb.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 12:41:50 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id 84si3400443ioi.91.2015.04.09.12.41.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 12:41:49 -0700 (PDT)
Received: by igblo3 with SMTP id lo3so850258igb.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 12:41:49 -0700 (PDT)
Date: Thu, 9 Apr 2015 12:41:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/hugetlb: use pmd_page() in follow_huge_pmd()
In-Reply-To: <1428595895-24140-1-git-send-email-gerald.schaefer@de.ibm.com>
Message-ID: <alpine.DEB.2.10.1504091235500.11370@chino.kir.corp.google.com>
References: <1428595895-24140-1-git-send-email-gerald.schaefer@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, 9 Apr 2015, Gerald Schaefer wrote:

> commit 61f77eda "mm/hugetlb: reduce arch dependent code around follow_huge_*"
> broke follow_huge_pmd() on s390, where pmd and pte layout differ and using
> pte_page() on a huge pmd will return wrong results. Using pmd_page() instead
> fixes this.
> 
> All architectures that were touched by commit 61f77eda have pmd_page()
> defined, so this should not break anything on other architectures.
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: stable@vger.kernel.org # v3.12

Acked-by: David Rientjes <rientjes@google.com>

I'm not sure where the stable cc came from, though: commit 61f77eda makes 
s390 use a generic version of follow_huge_pmd() and that generic version 
is buggy for s930 because of commit e66f17ff7177 ("mm/hugetlb: take page 
table lock in follow_huge_pmd()").  Both of those are 4.0 material, 
though, so why is this needed for stable 3.12?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
