Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCBD56B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 16:20:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so104737110pfb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:20:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bm3si11372122pad.35.2016.04.27.13.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 13:20:36 -0700 (PDT)
Date: Wed, 27 Apr 2016 13:20:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 00/13] Support non-lru page migration
Message-Id: <20160427132035.e96f99f3420c8fb0020b0fc4@linux-foundation.org>
In-Reply-To: <1461743305-19970-1-git-send-email-minchan@kernel.org>
References: <1461743305-19970-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

On Wed, 27 Apr 2016 16:48:13 +0900 Minchan Kim <minchan@kernel.org> wrote:

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
> 
> To solve these problem, this patch tries to add facility to migrate
> non-lru pages via introducing new functions and page flags to help
> migration.

I'm seeing some rejects here against Mel's changes and our patch
bandwidth is getting waaay way ahead of our review bandwidth.  So I
think I'll loadshed this patchset at this time, sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
