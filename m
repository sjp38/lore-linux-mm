Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 95CE4828DF
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 02:55:11 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id n5so15883587pfn.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:55:11 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id ai6si771386pad.181.2016.03.14.23.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 23:55:10 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id x3so15947646pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:55:10 -0700 (PDT)
Date: Tue, 15 Mar 2016 15:56:33 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 19/19] zram: use __GFP_MOVABLE for memory allocation
Message-ID: <20160315065633.GH1464@swordfish>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-20-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457681423-26664-20-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On (03/11/16 16:30), Minchan Kim wrote:
[..]
> init
> Node 0, zone      DMA    208    120     51     41     11      0      0      0      0      0      0
> Node 0, zone    DMA32  16380  13777   9184   3805    789     54      3      0      0      0      0
> compaction
> Node 0, zone      DMA    132     82     40     39     16      2      1      0      0      0      0
> Node 0, zone    DMA32   5219   5526   4969   3455   1831    677    139     15      0      0      0
> 
> new:
> 
> init
> Node 0, zone      DMA    379    115     97     19      2      0      0      0      0      0      0
> Node 0, zone    DMA32  18891  16774  10862   3947    637     21      0      0      0      0      0
> compaction  1
> Node 0, zone      DMA    214     66     87     29     10      3      0      0      0      0      0
> Node 0, zone    DMA32   1612   3139   3154   2469   1745    990    384     94      7      0      0
> 
> As you can see, compaction made so many high-order pages. Yay!
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
