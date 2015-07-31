Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9F16B0256
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:31:02 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so36742588wib.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:31:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si6064882wia.60.2015.07.31.08.31.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 08:31:00 -0700 (PDT)
Subject: Re: [PATCH v2 0/5] Assorted compaction cleanups and optimizations
References: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55BB94B3.7090603@suse.cz>
Date: Fri, 31 Jul 2015 17:30:59 +0200
MIME-Version: 1.0
In-Reply-To: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>

On 07/31/2015 05:28 PM, Vlastimil Babka wrote:
> v2 changes:
>   - dropped Patch 6 as adjusting to Joonsoo's objection would be too
>     complicated and the results didn't justify it
>   - don't check for compound order > 0 in patches 4 and 5 as suggested by
>     Michal Nazarewicz. Negative values are handled by converting to unsinged
>     int, the pfn calculations work fine with 0 and it's unlikely to see 0
>     due to a race when we just checked PageCompound().

ah, also patch 3 calls reset_cached_positions() from 
__reset_isolation_suitable() as v1 missed a callsite by doing it 
separately (spotted by Joonsoo)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
