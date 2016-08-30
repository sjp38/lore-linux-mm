Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBBE82F64
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 06:35:44 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id j12so32118938ywb.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 03:35:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j88si27001917qtd.51.2016.08.30.03.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 03:35:43 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7UAXe1p070201
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 06:35:43 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 255364mae3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 06:35:42 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 30 Aug 2016 04:35:30 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 2/6] mm/cma: introduce new zone, ZONE_CMA
In-Reply-To: <1472447255-10584-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com> <1472447255-10584-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 30 Aug 2016 16:05:20 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87vayisfx3.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>


....

>  static inline void check_highest_zone(enum zone_type k)
>  {
> -	if (k > policy_zone && k != ZONE_MOVABLE)
> +	if (k > policy_zone && k != ZONE_MOVABLE && !is_zone_cma_idx(k))
>  		policy_zone = k;
>  }
>


Should we apply policy to allocation from ZONE CMA ?. CMA reserve
happens early and may mostly come from one node. Do we want the
CMA allocation to fail if we use mbind(MPOL_BIND) with a node mask not
including that node on which CMA is reserved, considering CMA memory is
going to be used for special purpose.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
