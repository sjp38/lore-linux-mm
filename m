Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99F5528089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 22:54:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so219091915pfx.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 19:54:59 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id b2si8904619pll.243.2017.02.08.19.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 19:54:58 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id 75so16650709pgf.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 19:54:58 -0800 (PST)
Date: Thu, 9 Feb 2017 12:55:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: fix comment in zsmalloc
Message-ID: <20170209035516.GB2151@jagdpanzerIV.localdomain>
References: <1486610619-57588-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486610619-57588-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, guohanjun@huawei.com

On (02/09/17 11:23), Yisheng Xie wrote:
> The class index and fullness group are not encoded in
> (first)page->mapping any more, after commit 3783689a1aa8 ("zsmalloc:
> introduce zspage structure"). Instead, they are store in struct zspage.
> 
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Hanjun Guo <guohanjun@huawei.com>
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>

no objections from my side.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>




a side note - may be we don't need this comment at all.
the code looks like this:

/*
 * A zspage's class index and fullness group
 * are stored in struct zspage.
 */
#define FULLNESS_BITS	2
#define CLASS_BITS	8
#define ISOLATED_BITS	3
#define MAGIC_VAL_BITS	8

struct zspage {
	struct {
		unsigned int fullness:FULLNESS_BITS;
		unsigned int class:CLASS_BITS;
		unsigned int isolated:ISOLATED_BITS;
		unsigned int magic:MAGIC_VAL_BITS;
	};
	unsigned int inuse;
	unsigned int freeobj;
	struct page *first_page;
	struct list_head list; /* fullness list */
#ifdef CONFIG_COMPACTION
	rwlock_t lock;
#endif
};


so, basically, the comment just "repeats" the next 5 lines.
but, like I said, that's just a side note.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
