Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9EBC86B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 04:18:42 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id 124so131703222pfg.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 01:18:42 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id 13si6801009pft.59.2016.03.14.01.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 01:18:42 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id td3so124787269pab.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 01:18:41 -0700 (PDT)
Date: Mon, 14 Mar 2016 17:20:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v3 1/5] mm/zsmalloc: introduce class auto-compaction
Message-ID: <20160314082004.GE542@swordfish>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-2-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314061759.GC10675@bbox>
 <20160314074159.GA542@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160314074159.GA542@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (03/14/16 16:41), Sergey Senozhatsky wrote:
[..]
> you mean that __zs_compact() instead of just checking per-class
> zs_can_compact() should check global pool ratio and bail out if
> compaction of class Z has dropped the overall fragmentation ratio
> below some watermark?
> 
> my logic was that
>  -- suppose we have class A with fragmentation ratio 49% and class B
>  with 8% of wasted pages, so the overall pool fragmentation is
>  (50 + 10)/ 2 < 30%, while we still have almost 50% fragmented class.

  "(49 + 8) / 2 < 30%"

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
