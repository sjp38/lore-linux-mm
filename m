Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC6956B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 17:41:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so23902327pfc.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 14:41:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 67si5539970pfp.63.2016.06.01.14.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 14:41:53 -0700 (PDT)
Date: Wed, 1 Jun 2016 14:41:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 00/12] Support non-lru page migration
Message-Id: <20160601144151.c9e5c560be29cae9a3ff1f1e@linux-foundation.org>
In-Reply-To: <1464736881-24886-1-git-send-email-minchan@kernel.org>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

On Wed,  1 Jun 2016 08:21:09 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Recently, I got many reports about perfermance degradation in embedded
> system(Android mobile phone, webOS TV and so on) and easy fork fail.
> 
> The problem was fragmentation caused by zram and GPU driver mainly.
> With memory pressure, their pages were spread out all of pageblock and
> it cannot be migrated with current compaction algorithm which supports
> only LRU pages. In the end, compaction cannot work well so reclaimer
> shrinks all of working set pages. It made system very slow and even to
> fail to fork easily which requires order-[2 or 3] allocations.
> 
> Other pain point is that they cannot use CMA memory space so when OOM
> kill happens, I can see many free pages in CMA area, which is not
> memory efficient. In our product which has big CMA memory, it reclaims
> zones too exccessively to allocate GPU and zram page although there are
> lots of free space in CMA so system becomes very slow easily.

But this isn't presently implemented for GPU drivers or for CMA, yes?

What's the story there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
