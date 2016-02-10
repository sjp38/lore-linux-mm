Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5876B0254
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 07:52:13 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id 128so25458839wmz.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 04:52:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g126si30280774wma.21.2016.02.10.04.52.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Feb 2016 04:52:12 -0800 (PST)
Subject: Re: [PATCH v2 2/3] mm/compaction: pass only pageblock aligned range
 to pageblock_pfn_to_page
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1454566775-30973-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56BB3278.3020907@suse.cz>
Date: Wed, 10 Feb 2016 13:52:08 +0100
MIME-Version: 1.0
In-Reply-To: <1454566775-30973-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/04/2016 07:19 AM, Joonsoo Kim wrote:
> pageblock_pfn_to_page() is used to check there is valid pfn and all pages
> in the pageblock is in a single zone. If there is a hole in the pageblock,
> passing arbitrary position to pageblock_pfn_to_page() could cause to skip
> whole pageblock scanning, instead of just skipping the hole page. For
> deterministic behaviour, it's better to always pass pageblock aligned
> range to pageblock_pfn_to_page(). It will also help further optimization
> on pageblock_pfn_to_page() in the following patch.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
