Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDCC82970
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:45:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so54128471wmz.2
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:45:19 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id jv2si39049036wjc.268.2016.08.10.02.45.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 02:45:18 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id o80so8437584wme.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:45:18 -0700 (PDT)
Date: Wed, 10 Aug 2016 18:44:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 2/5] mm/debug_pagealloc: don't allocate page_ext if we
 don't use guard page
Message-ID: <20160810094442.GA674@swordfish>
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470809784-11516-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470809784-11516-3-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On (08/10/16 15:16), js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> What debug_pagealloc does is just mapping/unmapping page table.
> Basically, it doesn't need additional memory space to memorize something.
> But, with guard page feature, it requires additional memory to distinguish
> if the page is for guard or not. Guard page is only used when
> debug_guardpage_minorder is non-zero so this patch removes additional
> memory allocation (page_ext) if debug_guardpage_minorder is zero.
> 
> It saves memory if we just use debug_pagealloc and not guard page.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
