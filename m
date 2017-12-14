Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69E626B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:29:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b82so2455427wmd.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:29:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60si3286153wrq.164.2017.12.14.03.29.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 03:29:31 -0800 (PST)
Date: Thu, 14 Dec 2017 12:29:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2] mm/mprotect: Add a cond_resched() inside
 change_pmd_range()
Message-ID: <20171214112928.GH16951@dhcp22.suse.cz>
References: <20171214111426.25912-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214111426.25912-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Thu 14-12-17 16:44:26, Anshuman Khandual wrote:
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index ec39f73..43c29fa 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -196,6 +196,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
>  				 dirty_accountable, prot_numa);
>  		pages += this_pages;
> +		cond_resched();
>  	} while (pmd++, addr = next, addr != end);
>  
>  	if (mni_start)

this is not exactly what I meant. See how change_huge_pmd does continue.
That's why I mentioned zap_pmd_range which does goto next...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
