Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 100A56B025E
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:30:04 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so31518677lfw.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:30:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q197si3985446wmb.145.2016.08.19.06.30.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 06:30:02 -0700 (PDT)
Subject: Re: [PATCH v4 4/5] mm/cma: remove MIGRATE_CMA
References: <1470724759-855-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470724759-855-5-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1f79f242-b51a-f9c8-848d-f12ee378dde5@suse.cz>
Date: Fri, 19 Aug 2016 15:29:59 +0200
MIME-Version: 1.0
In-Reply-To: <1470724759-855-5-git-send-email-iamjoonsoo.kim@lge.com>
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
> and there is no other type of pages. Therefore, we don't need to
> use MIGRATE_CMA to distinguish and handle differently for CMA pages
> and ordinary pages. Remove MIGRATE_CMA.
>
> Unfortunately, this patch make free CMA counter incorrect because
> we count it when pages are on the MIGRATE_CMA. It will be fixed
> by next patch. I can squash next patch here but it makes changes
> complicated and hard to review so I separate that.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
