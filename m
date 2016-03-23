Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B3C316B0253
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 10:38:46 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id r129so139516248wmr.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 07:38:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 78si4123120wmw.56.2016.03.23.07.38.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 07:38:45 -0700 (PDT)
Subject: Re: [PATCH 3/6] mm/memory_hotplug: add comment to some functions
 related to memory hotplug
References: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1457940697-2278-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56F2AA74.6070808@suse.cz>
Date: Wed, 23 Mar 2016 15:38:44 +0100
MIME-Version: 1.0
In-Reply-To: <1457940697-2278-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/14/2016 08:31 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> __offline_isolated_pages() and test_pages_isolated() are used by memory
> hotplug. These functions require that range is in a single zone but
> there is no code about it because memory hotplug checks it before calling
> these functions. Not to confuse future user of these functions,
> this patch adds comment on them.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
