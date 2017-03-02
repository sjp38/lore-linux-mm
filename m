Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id ABF146B0388
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 09:33:23 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d18so93385926pgh.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 06:33:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i9si7607107plk.73.2017.03.02.06.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 06:33:22 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v22ETpe1140322
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 09:33:22 -0500
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xen2kc7c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:33:21 -0500
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 2 Mar 2017 20:03:18 +0530
Received: from d28relay08.in.ibm.com (d28relay08.in.ibm.com [9.184.220.159])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 17CA4E0024
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 20:05:03 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay08.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v22EWAWs13631582
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 20:02:10 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v22EXGSX014417
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 20:03:16 +0530
Subject: Re: [RFC 02/11] mm: remove unncessary ret in page_referenced
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-3-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 2 Mar 2017 20:03:16 +0530
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <2baf1168-0f84-b80d-5fb9-9d13c618c9f1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On 03/02/2017 12:09 PM, Minchan Kim wrote:
> Anyone doesn't use ret variable. Remove it.
> 

This change is correct. But not sure how this is related to
try_to_unmap() clean up though.


> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/rmap.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index bb45712..8076347 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -805,7 +805,6 @@ int page_referenced(struct page *page,
>  		    struct mem_cgroup *memcg,
>  		    unsigned long *vm_flags)
>  {
> -	int ret;
>  	int we_locked = 0;
>  	struct page_referenced_arg pra = {
>  		.mapcount = total_mapcount(page),
> @@ -839,7 +838,7 @@ int page_referenced(struct page *page,
>  		rwc.invalid_vma = invalid_page_referenced_vma;
>  	}
>  
> -	ret = rmap_walk(page, &rwc);
> +	rmap_walk(page, &rwc);
>  	*vm_flags = pra.vm_flags;
>  
>  	if (we_locked)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
