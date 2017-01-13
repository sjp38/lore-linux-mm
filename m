Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1485B6B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:40:47 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so13218724wmi.6
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 00:40:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o79si1323545wme.32.2017.01.13.00.40.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 00:40:45 -0800 (PST)
Date: Fri, 13 Jan 2017 09:40:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2 linux-next] userfaultfd: hugetlbfs: unmap the correct
 pointer
Message-ID: <20170113084044.GC25212@dhcp22.suse.cz>
References: <20170112193327.GB8558@dhcp22.suse.cz>
 <20170113082608.GA3548@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113082608.GA3548@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Fri 13-01-17 11:26:08, Dan Carpenter wrote:
> kunmap_atomic() and kunmap() take different pointers.  People often get
> these mixed up.
> 
> Fixes: 16374db2e9a0 ("userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> v2: I was also unmapping the wrong pointer because I had a typo.
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 6012a05..aca8ef6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4172,7 +4172,7 @@ long copy_huge_page_from_user(struct page *dst_page,
>  				(const void __user *)(src + i * PAGE_SIZE),
>  				PAGE_SIZE);
>  		if (allow_pagefault)
> -			kunmap(page_kaddr);
> +			kunmap(page_kaddr + i);
>  		else
>  			kunmap_atomic(page_kaddr);
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
