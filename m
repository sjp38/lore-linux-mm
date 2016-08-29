Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 622BE830E7
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 05:27:42 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id vd14so258709584pab.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 02:27:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u2si38224607paw.283.2016.08.29.02.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 02:27:41 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7T9NZEf012075
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 05:27:41 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2533rksv0c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 05:27:40 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Aug 2016 05:27:39 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 0/6] Introduce ZONE_CMA
In-Reply-To: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 29 Aug 2016 14:57:29 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <8737lnudq6.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

js1304@gmail.com writes:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Hello,
>
> Changes from v4
> o Rebase on next-20160825
> o Add general fix patch for lowmem reserve
> o Fix lowmem reserve ratio
> o Fix zone span optimizaion per Vlastimil
> o Fix pageset initialization
> o Change invocation timing on cma_init_reserved_areas()

I don't see much information regarding how we interleave between
ZONE_CMA and other zones for movable allocation. Is that explained in
any of the patch ? The fair zone allocator got removed by
e6cbd7f2efb433d717af72aa8510a9db6f7a7e05 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
