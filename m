Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 809366B0035
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:52:50 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so10219807pbb.22
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 18:52:50 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id zt8si11780522pbc.359.2014.04.15.18.52.47
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 18:52:49 -0700 (PDT)
Date: Wed, 16 Apr 2014 10:53:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
Message-ID: <20140416015314.GB17841@js1304-P5Q-DELUXE>
References: <5342BA34.8050006@suse.cz>
 <1397553507-15330-1-git-send-email-vbabka@suse.cz>
 <1397553507-15330-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397553507-15330-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Tue, Apr 15, 2014 at 11:18:27AM +0200, Vlastimil Babka wrote:
> isolate_freepages() is currently somewhat hard to follow thanks to many
> different pfn variables. Especially misleading is the name 'high_pfn' which
> looks like it is related to the 'low_pfn' variable, but in fact it is not.
> 
> This patch renames the 'high_pfn' variable to a hopefully less confusing name,
> and slightly changes its handling without a functional change. A comment made
> obsolete by recent changes is also updated.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/compaction.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
