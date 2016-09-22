Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E79D96B026E
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 06:58:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n24so158163395pfb.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 03:58:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d9si1653496pag.62.2016.09.22.03.58.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 03:58:36 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8MAwXB0124230
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 06:58:35 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25mcrrbrc9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 06:58:34 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 22 Sep 2016 06:58:19 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] shmem: fix tmpfs to handle the huge= option properly
In-Reply-To: <1473459863-11287-2-git-send-email-toshi.kani@hpe.com>
References: <1473459863-11287-1-git-send-email-toshi.kani@hpe.com> <1473459863-11287-2-git-send-email-toshi.kani@hpe.com>
Date: Thu, 22 Sep 2016 16:28:10 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <8737ksw69p.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>, akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, mawilcox@microsoft.com, hughd@google.com, kirill.shutemov@linux.intel.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Toshi Kani <toshi.kani@hpe.com> writes:

> shmem_get_unmapped_area() checks SHMEM_SB(sb)->huge incorrectly,
> which leads to a reversed effect of "huge=" mount option.
>
> Fix the check in shmem_get_unmapped_area().
>
> Note, the default value of SHMEM_SB(sb)->huge remains as
> SHMEM_HUGE_NEVER.  User will need to specify "huge=" option to
> enable huge page mappings.
>

Any update on getting this merged ?

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> Reported-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> ---
>  mm/shmem.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index fd8b2b5..aec5b49 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1980,7 +1980,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
>  				return addr;
>  			sb = shm_mnt->mnt_sb;
>  		}
> -		if (SHMEM_SB(sb)->huge != SHMEM_HUGE_NEVER)
> +		if (SHMEM_SB(sb)->huge == SHMEM_HUGE_NEVER)
>  			return addr;
>  	}
>  
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
