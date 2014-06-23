Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1EA6B0035
	for <linux-mm@kvack.org>; Sun, 22 Jun 2014 23:04:01 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so5277765pbc.17
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 20:04:01 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ko1si19778121pbc.100.2014.06.22.20.03.59
        for <linux-mm@kvack.org>;
        Sun, 22 Jun 2014 20:04:00 -0700 (PDT)
Date: Mon, 23 Jun 2014 12:04:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 08/13] mm, compaction: remember position within
 pageblock in free pages scanner
Message-ID: <20140623030448.GD12413@bbox>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
 <1403279383-5862-9-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1403279383-5862-9-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 05:49:38PM +0200, Vlastimil Babka wrote:
> Unlike the migration scanner, the free scanner remembers the beginning of the
> last scanned pageblock in cc->free_pfn. It might be therefore rescanning pages
> uselessly when called several times during single compaction. This might have
> been useful when pages were returned to the buddy allocator after a failed
> migration, but this is no longer the case.
> 
> This patch changes the meaning of cc->free_pfn so that if it points to a
> middle of a pageblock, that pageblock is scanned only from cc->free_pfn to the
> end. isolate_freepages_block() will record the pfn of the last page it looked
> at, which is then used to update cc->free_pfn.
> 
> In the mmtests stress-highalloc benchmark, this has resulted in lowering the
> ratio between pages scanned by both scanners, from 2.5 free pages per migrate
> page, to 2.25 free pages per migrate page, without affecting success rates.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
