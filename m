Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 331C58E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 06:26:11 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 80so1975462qkd.0
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:26:11 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m68si8116587qkd.120.2019.01.15.03.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 03:26:09 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0FBPI1j033137
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 06:26:09 -0500
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q1dnvajwn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 06:26:09 -0500
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 15 Jan 2019 11:26:07 -0000
Subject: Re: [PATCH V7 5/5] testing
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
 <20190114095438.32470-7-aneesh.kumar@linux.ibm.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Tue, 15 Jan 2019 16:55:57 +0530
MIME-Version: 1.0
In-Reply-To: <20190114095438.32470-7-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <bd6b4237-064d-0059-3b2c-1f14cdf466f2@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

You can ignore this one.

On 1/14/19 3:24 PM, Aneesh Kumar K.V wrote:
> ---
>   mm/gup.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 6e8152594e83..91849c39931a 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1226,7 +1226,7 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
>   		 * be pinning these entries, we might as well move them out
>   		 * of the CMA zone if possible.
>   		 */
> -		if (is_migrate_cma_page(pages[i])) {
> +		if (true || is_migrate_cma_page(pages[i])) {
>   
>   			struct page *head = compound_head(pages[i]);
>   
> @@ -1256,6 +1256,7 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
>   		for (i = 0; i < nr_pages; i++)
>   			put_page(pages[i]);
>   
> +		pr_emerg("migrating nr_pages");
>   		if (migrate_pages(&cma_page_list, new_non_cma_page,
>   				  NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE)) {
>   			/*
> @@ -1274,10 +1275,11 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
>   		nr_pages = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
>   		if ((nr_pages > 0) && migrate_allow) {
>   			drain_allow = true;
> -			goto check_again;
> +			//goto check_again;
>   		}
>   	}
>   
> +	pr_emerg("Returning with %ld\n", nr_pages);
>   	return nr_pages;
>   }
>   #else
> 
