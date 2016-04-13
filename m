Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 518ED6B0005
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 03:54:21 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id u206so61547958wme.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 00:54:21 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id y15si28021487wmd.12.2016.04.13.00.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 00:54:19 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n3so11515284wmn.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 00:54:19 -0700 (PDT)
Date: Wed, 13 Apr 2016 09:54:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 01/10] mm/mmap: Replace SHM_HUGE_MASK with MAP_HUGE_MASK
 inside mmap_pgoff
Message-ID: <20160413075417.GA14356@dhcp22.suse.cz>
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1460007464-26726-2-git-send-email-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460007464-26726-2-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

On Thu 07-04-16 11:07:35, Anshuman Khandual wrote:
> The commit 091d0d55b286 ("shm: fix null pointer deref when userspace
> specifies invalid hugepage size") had replaced MAP_HUGE_MASK with
> SHM_HUGE_MASK. Though both of them contain the same numeric value of
> 0x3f, MAP_HUGE_MASK flag sounds more appropriate than the other one
> in the context. Hence change it back.

Yes, SHM_HUGE_MASK mixing with MAP_HUGE_SHIFT is not only misleading
it might bite us later should any of the two change.

> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index bd2e1a53..7d730a4 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1315,7 +1315,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  		struct user_struct *user = NULL;
>  		struct hstate *hs;
>  
> -		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & SHM_HUGE_MASK);
> +		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
>  		if (!hs)
>  			return -EINVAL;
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
