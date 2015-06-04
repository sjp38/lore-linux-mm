Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 47E87900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 10:48:04 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so32444277pdb.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 07:48:04 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id el11si6151230pac.237.2015.06.04.07.48.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 07:48:03 -0700 (PDT)
Received: by padj3 with SMTP id j3so31067250pad.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 07:48:03 -0700 (PDT)
Date: Thu, 4 Jun 2015 23:47:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCH 07/10] zsmalloc: introduce auto-compact support
Message-ID: <20150604144730.GA484@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604045725.GI2241@blaptop>
 <20150604053056.GA662@swordfish>
 <20150604062712.GJ2241@blaptop>
 <20150604070416.GK2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604070416.GK2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (06/04/15 16:04), Minchan Kim wrote:
[..]
> How about using slab shrinker?
> If there is memory pressure, it would be called by VM and we will
> try compaction without user's intervention and excessive object
> scanning should be avoid by your zs_can_compact.

hm, interesting.

ok, have a patch to trigger compaction from shrinker, but need to test
it more.

will send the updated patchset tomorrow, I think.

	-ss

> The concern I had about fragmentation spread out all over pageblock
> should be solved as another issue. I'm plaing to make zsmalloced
> page migratable. I hope we should work out it firstly to prevent
> system heavy memory fragmentation by automatic compaction.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
