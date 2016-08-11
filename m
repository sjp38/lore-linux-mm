Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA8296B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 05:53:21 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so2444284wml.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 02:53:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10si2204239wmh.11.2016.08.11.02.53.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 02:53:20 -0700 (PDT)
Subject: Re: [PATCH 2/5] mm/debug_pagealloc: don't allocate page_ext if we
 don't use guard page
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470809784-11516-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7391d520-0512-231b-ef2d-600ab22bda5b@suse.cz>
Date: Thu, 11 Aug 2016 11:53:18 +0200
MIME-Version: 1.0
In-Reply-To: <1470809784-11516-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/10/2016 08:16 AM, js1304@gmail.com wrote:
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

We could also save cycles with a static key for _debug_guardpage_enabled :)

But memory savings are likely more significant, so

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
