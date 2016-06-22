Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2E1F6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:02:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so240759wma.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:02:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a139si68157wmd.56.2016.06.22.04.02.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 04:02:33 -0700 (PDT)
Subject: Re: [patch] mm, compaction: abort free scanner if split fails
References: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1606211820350.97086@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <19433d36-76e4-4c0a-0d5b-ff52b169b983@suse.cz>
Date: Wed, 22 Jun 2016 13:02:30 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1606211820350.97086@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On 06/22/2016 03:22 AM, David Rientjes wrote:
> If the memory compaction free scanner cannot successfully split a free
> page (only possible due to per-zone low watermark), terminate the free
> scanner rather than continuing to scan memory needlessly.  If the
> watermark is insufficient for a free page of order <= cc->order, then
> terminate the scanner since all future splits will also likely fail.
>
> This prevents the compaction freeing scanner from scanning all memory on
> very large zones (very noticeable for zones > 128GB, for instance) when
> all splits will likely fail while holding zone->lock.
>
> Cc: stable@vger.kernel.org
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  Based on Linus's tree
>
>  Suggest including in 4.7 if anybody else agrees?

4.7 definitely. Stable is less clear especially if you say it won't apply 
cleanly, but if you're ready to handle it, sure. The rules now allow fixing 
glaring performance bugs.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
