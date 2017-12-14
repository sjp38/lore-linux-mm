Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 907056B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:33:34 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id t92so2894737wrc.13
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 01:33:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 200si2895624wmw.71.2017.12.14.01.33.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 01:33:33 -0800 (PST)
Date: Thu, 14 Dec 2017 10:33:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mprotect: Add a cond_resched() inside
 change_pte_range()
Message-ID: <20171214093332.GG16951@dhcp22.suse.cz>
References: <20171214051021.20880-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214051021.20880-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Thu 14-12-17 10:40:21, Anshuman Khandual wrote:
[...]
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index ec39f73..4fce0f5 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -144,6 +144,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(pte - 1, ptl);
> +	cond_resched();
>  
>  	return pages;
>  }

I would put this one level up to change_pmd_range to catch large THP
backed regions. Something we do in zap_pmd_range. Other than that the
patch makes sense to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
