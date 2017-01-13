Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA0E6B0253
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 01:36:03 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 203so48973491ith.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 22:36:03 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id o8si11738360pgn.24.2017.01.12.22.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 22:36:02 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 127so6920696pfg.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 22:36:02 -0800 (PST)
Date: Fri, 13 Jan 2017 15:36:14 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170113063614.GA484@jagdpanzerIV.localdomain>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <20170109234110.GA10298@bbox>
 <20170113042444.GE9360@jagdpanzerIV.localdomain>
 <20170113062343.GA7827@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113062343.GA7827@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, zhouxianrong@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On (01/13/17 15:23), Minchan Kim wrote:
[..]
> > > Please add same_pages to tail of the stat
> > 
> > sounds ok to me. and yes, can deprecate zero_pages.
> > 
> > seems that with that patch the concept of ZRAM_ZERO disappears. both
> > ZERO and SAME_ELEMENT pages are considered to be the same thing now.
> 
> Right.
> 
> > which is fine and makes sense to me, I think. and if ->.same_pages will
> > replace ->.zero_pages in mm_stat() then I'm also OK. yes, we will see
> > increased number in the last column of mm_stat file, but I don't tend
> > to see any issues here. Minchan, what do you think?
> 
> Could you elaborate a bit? Do you mean this?
> 
>         ret = scnprintf(buf, PAGE_SIZE,
>                         "%8llu %8llu %8llu %8lu %8ld %8llu %8lu\n",
>                         orig_size << PAGE_SHIFT,
>                         (u64)atomic64_read(&zram->stats.compr_data_size),
>                         mem_used << PAGE_SHIFT,
>                         zram->limit_pages << PAGE_SHIFT,
>                         max_used << PAGE_SHIFT,
>                         // (u64)atomic64_read(&zram->stats.zero_pages),
>                         (u64)atomic64_read(&zram->stats.same_pages),
>                         pool_stats.pages_compacted);

yes, correct.

do we need to export it as two different stats (zero_pages and
same_pages), if those are basically same thing internally?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
