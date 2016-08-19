Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C260F6B0253
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:12:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so17671344wmu.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:12:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a64si3954743wmc.86.2016.08.19.06.12.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 06:12:23 -0700 (PDT)
Subject: Re: [PATCH v4 3/5] mm/cma: remove ALLOC_CMA
References: <1470724759-855-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470724759-855-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2c33b4f8-b347-9554-f2b9-4c582130ab2d@suse.cz>
Date: Fri, 19 Aug 2016 15:12:19 +0200
MIME-Version: 1.0
In-Reply-To: <1470724759-855-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/09/2016 08:39 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Now, all reserved pages for CMA region are belong to the ZONE_CMA
> and it only serves for GFP_HIGHUSER_MOVABLE. Therefore, we don't need to
> consider ALLOC_CMA at all.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
