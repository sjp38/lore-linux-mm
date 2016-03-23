Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5546B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 10:38:21 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id l68so27276318wml.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 07:38:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wl9si3480792wjb.220.2016.03.23.07.38.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 07:38:20 -0700 (PDT)
Subject: Re: [PATCH 2/6] mm/hugetlb: add same zone check in
 pfn_range_valid_gigantic()
References: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1457940697-2278-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56F2AA59.9060208@suse.cz>
Date: Wed, 23 Mar 2016 15:38:17 +0100
MIME-Version: 1.0
In-Reply-To: <1457940697-2278-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/14/2016 08:31 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> alloc_gigantic_page() uses alloc_contig_range() and this
> requires that requested range is in a single zone. To satisfy
> that requirement, add this check to pfn_range_valid_gigantic().
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
