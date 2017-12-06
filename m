Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ADE866B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 12:43:21 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 11so2466184wrb.18
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 09:43:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g91si3032836edd.352.2017.12.06.09.43.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 09:43:20 -0800 (PST)
Date: Wed, 6 Dec 2017 18:43:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 26/45] mm: remove duplicate includes
Message-ID: <20171206174317.GH7515@dhcp22.suse.cz>
References: <1512580957-6071-1-git-send-email-pravin.shedge4linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1512580957-6071-1-git-send-email-pravin.shedge4linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin Shedge <pravin.shedge4linux@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

On Wed 06-12-17 22:52:37, Pravin Shedge wrote:
> These duplicate includes have been found with scripts/checkincludes.pl but
> they have been removed manually to avoid removing false positives.

I only see this one but I can see this is a series of 45 patches. Is
this really the best way to apply a change like this? Why not do it in a
single patch?
 
Other than that the patch looks correct.

> Signed-off-by: Pravin Shedge <pravin.shedge4linux@gmail.com>
> ---
>  mm/userfaultfd.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index 8119270..39791b8 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -16,7 +16,6 @@
>  #include <linux/userfaultfd_k.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/hugetlb.h>
> -#include <linux/pagemap.h>
>  #include <linux/shmem_fs.h>
>  #include <asm/tlbflush.h>
>  #include "internal.h"
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
