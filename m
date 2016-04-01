Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 081D36B007E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 04:19:12 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id 127so11276521wmu.1
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 01:19:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j16si33710521wmd.103.2016.04.01.01.19.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Apr 2016 01:19:10 -0700 (PDT)
Subject: Re: [PATCH v2 3/5] mm/vmstat: add zone range overlapping check
References: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459476406-28418-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FE2EFF.3070509@suse.cz>
Date: Fri, 1 Apr 2016 10:19:11 +0200
MIME-Version: 1.0
In-Reply-To: <1459476406-28418-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 1.4.2016 4:06, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> There is a system that node's pfn are overlapped like as following.
> 
> -----pfn-------->
> N0 N1 N2 N0 N1 N2
> 
> Therefore, we need to care this overlapping when iterating pfn range.
> 
> There are two places in vmstat.c that iterates pfn range and
> they don't consider this overlapping. Add it.
> 
> Without this patch, above system could over count pageblock number
> on a zone.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
