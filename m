Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0D383096
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 08:41:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so41775877pfd.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 05:41:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g8si33847921pan.207.2016.08.30.05.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 05:41:03 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7UCeuBx078818
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 08:41:02 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2558r4vbmw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 08:41:02 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 30 Aug 2016 08:40:57 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 2/6] mm/cma: introduce new zone, ZONE_CMA
In-Reply-To: <87vayisfx3.fsf@linux.vnet.ibm.com>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com> <1472447255-10584-3-git-send-email-iamjoonsoo.kim@lge.com> <87vayisfx3.fsf@linux.vnet.ibm.com>
Date: Tue, 30 Aug 2016 18:10:46 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87pooqsa41.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> ....
>
>>  static inline void check_highest_zone(enum zone_type k)
>>  {
>> -	if (k > policy_zone && k != ZONE_MOVABLE)
>> +	if (k > policy_zone && k != ZONE_MOVABLE && !is_zone_cma_idx(k))
>>  		policy_zone = k;
>>  }
>>
>
>
> Should we apply policy to allocation from ZONE CMA ?. CMA reserve
> happens early and may mostly come from one node. Do we want the
> CMA allocation to fail if we use mbind(MPOL_BIND) with a node mask not
> including that node on which CMA is reserved, considering CMA memory is
> going to be used for special purpose.

Looking at this again, I guess CMA alloc is not going to depend on
memory policy, but this is for other movable allocation ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
