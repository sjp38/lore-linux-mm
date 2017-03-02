Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 11AD16B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 09:27:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so83985748pfb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 06:27:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f6si7565489plj.297.2017.03.02.06.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 06:27:18 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v22EJjGK012097
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 09:27:17 -0500
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xjam8tvd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:27:17 -0500
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 2 Mar 2017 19:57:14 +0530
Received: from d28relay10.in.ibm.com (d28relay10.in.ibm.com [9.184.220.161])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id B369BE005F
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 19:58:57 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v22EQ5aL16384084
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 19:56:05 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v22ERBaJ024502
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 19:57:11 +0530
Subject: Re: [RFC 01/11] mm: use SWAP_SUCCESS instead of 0
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-2-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 2 Mar 2017 19:57:10 +0530
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <e7a05d50-4fa8-66ce-9aa0-df54f21be0d8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill@shutemov.name>

On 03/02/2017 12:09 PM, Minchan Kim wrote:
> SWAP_SUCCESS defined value 0 can be changed always so don't rely on
> it. Instead, use explict macro.

Right. But should not we move the changes to the callers last in the
patch series after doing the cleanup to the try_to_unmap() function
as intended first.

> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/huge_memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 092cc5c..fe2ccd4 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2114,7 +2114,7 @@ static void freeze_page(struct page *page)
>  		ttu_flags |= TTU_MIGRATION;
>  
>  	ret = try_to_unmap(page, ttu_flags);
> -	VM_BUG_ON_PAGE(ret, page);
> +	VM_BUG_ON_PAGE(ret != SWAP_SUCCESS, page);
>  }
>  
>  static void unfreeze_page(struct page *page)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
