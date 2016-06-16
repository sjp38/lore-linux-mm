Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 951D36B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:42:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so92071918pfb.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:42:12 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id g7si4886620pfg.88.2016.06.16.01.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 01:42:11 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id ts6so3308834pac.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:42:11 -0700 (PDT)
Date: Thu, 16 Jun 2016 17:42:11 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v7 00/12] Support non-lru page migration
Message-ID: <20160616084211.GA432@swordfish>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <20160615075909.GA425@swordfish>
 <20160615231248.GI17127@bbox>
 <20160616024827.GA497@swordfish>
 <20160616025800.GO17127@bbox>
 <20160616042343.GA516@swordfish>
 <20160616044710.GP17127@bbox>
 <20160616052209.GB516@swordfish>
 <20160616064753.GR17127@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616064753.GR17127@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

On (06/16/16 15:47), Minchan Kim wrote:
> > [..]
> > > > this is what I'm getting with the [zsmalloc: keep first object offset in struct page]
> > > > applied:  "count:0 mapcount:-127". which may be not related to zsmalloc at this point.
> > > > 
> > > > kernel: BUG: Bad page state in process khugepaged  pfn:101db8
> > > > kernel: page:ffffea0004076e00 count:0 mapcount:-127 mapping:          (null) index:0x1
> > > 
> > > Hm, it seems double free.
> > > 
> > > It doen't happen if you disable zram? IOW, it seems to be related
> > > zsmalloc migration?
> > 
> > need to test more, can't confidently answer now.
> > 
> > > How easy can you reprodcue it? Could you bisect it?
> > 
> > it takes some (um.. random) time to trigger the bug.
> > I'll try to come up with more details.
> 
> Could you revert [1] and retest?
> 
> [1] mm/compaction: split freepages without holding the zone lock

ok, so this is not related to zsmalloc. finally manged to reproduce
it. will fork a separate thread.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
