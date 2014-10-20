Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 70DA06B0070
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:18:50 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id i17so3906490qcy.30
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 08:18:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g6si16788873qgf.49.2014.10.20.08.18.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 08:18:49 -0700 (PDT)
Message-ID: <544527CE.8090607@redhat.com>
Date: Mon, 20 Oct 2014 11:18:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mm, compaction: defer only on COMPACT_COMPLETE
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz> <1412696019-21761-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412696019-21761-4-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On 10/07/2014 11:33 AM, Vlastimil Babka wrote:
> Deferred compaction is employed to avoid compacting zone where sync direct
> compaction has recently failed. As such, it makes sense to only defer when
> a full zone was scanned, which is when compact_zone returns with
> COMPACT_COMPLETE. It's less useful to defer when compact_zone returns with
> apparent success (COMPACT_PARTIAL), followed by a watermark check failure,
> which can happen due to parallel allocation activity. It also does not make
> much sense to defer compaction which was completely skipped (COMPACT_SKIP) for
> being unsuitable in the first place.
>
> This patch therefore makes deferred compaction trigger only when
> COMPACT_COMPLETE is returned from compact_zone(). Results of stress-highalloc
> becnmark show the difference is within measurement error, so the issue is
> rather cosmetic.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
