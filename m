Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id CBD116B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 18:38:43 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so468656igb.17
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 15:38:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f4si5470020icx.73.2014.11.21.15.38.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Nov 2014 15:38:43 -0800 (PST)
Date: Fri, 21 Nov 2014 15:38:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 7/7] mm/page_owner: correct owner information for
 early allocated pages
Message-Id: <20141121153841.c15fa400fd5c76d3946523a8@linux-foundation.org>
In-Reply-To: <1416557646-21755-8-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416557646-21755-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1416557646-21755-8-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 21 Nov 2014 17:14:06 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> Extended memory to store page owner information is initialized some time
> later than that page allocator starts. Until initialization, many pages
> can be allocated and they have no owner information. This make debugging
> using page owner harder, so some fixup will be helpful.
> 
> This patch fix up this situation by setting fake owner information
> immediately after page extension is initialized. Information doesn't
> tell the right owner, but, at least, it can tell whether page is
> allocated or not, more correctly.
> 
> On my testing, this patch catches 13343 early allocated pages, although
> they are mostly allocated from page extension feature. Anyway, after then,
> there is no page left that it is allocated and has no page owner flag.

We really should have a Documentation/vm/page_owner.txt which explains
all this stuff, provides examples, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
