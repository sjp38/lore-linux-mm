Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5E319828DF
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 02:18:24 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id n5so14580516pfn.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:18:24 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id z12si4712996pas.77.2016.03.14.23.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 23:18:23 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id x3so14630242pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:18:23 -0700 (PDT)
Date: Tue, 15 Mar 2016 15:19:46 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 06/19] zsmalloc: clean up many BUG_ON
Message-ID: <20160315061946.GB1464@swordfish>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-7-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457681423-26664-7-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On (03/11/16 16:30), Minchan Kim wrote:
> There are many BUG_ON in zsmalloc.c which is not recommened so
> change them as alternatives.
> 
> Normal rule is as follows:
> 
> 1. avoid BUG_ON if possible. Instead, use VM_BUG_ON or VM_BUG_ON_PAGE
> 2. use VM_BUG_ON_PAGE if we need to see struct page's fields
> 3. use those assertion in primitive functions so higher functions
> can rely on the assertion in the primitive function.
> 4. Don't use assertion if following instruction can trigger Oops
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
