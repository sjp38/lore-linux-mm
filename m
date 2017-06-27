Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E62D86B02C3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 00:56:46 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u62so18270561pgb.13
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 21:56:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g85si1238048pfd.255.2017.06.26.21.56.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 21:56:45 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5R4s29x136744
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 00:56:45 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bb4bq2nya-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 00:56:45 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 27 Jun 2017 14:56:42 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v5R4uetm393494
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 14:56:40 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v5R4uWfo014808
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 14:56:32 +1000
Subject: Re: [PATCH] mm/memory_hotplug: remove an unused variable in
 move_pfn_range_to_zone()
References: <20170626231928.54565-1-richard.weiyang@gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 27 Jun 2017 10:26:38 +0530
MIME-Version: 1.0
In-Reply-To: <20170626231928.54565-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <6a58b706-f409-b81f-4859-a6323bce1758@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/27/2017 04:49 AM, Wei Yang wrote:
> There is an unused variable in move_pfn_range_to_zone().
> 
> This patch just removes it.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/memory_hotplug.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 514014dde16b..16167c92bbf1 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -899,7 +899,6 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
>  	struct pglist_data *pgdat = zone->zone_pgdat;
>  	int nid = pgdat->node_id;
>  	unsigned long flags;
> -	unsigned long i;
>  
>  	if (zone_is_empty(zone))
>  		init_currently_empty_zone(zone, start_pfn, nr_pages);

We have this down in the function. IIRC I had checked out tag
mmotm-2017-06-16-13-59 where I am looking out for this function.

for (i = 0; i < nr_pages; i++) {
	unsigned long pfn = start_pfn + i;
	set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
