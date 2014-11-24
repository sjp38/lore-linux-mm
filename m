Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 385C4800CA
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 22:07:24 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so8651024pab.12
        for <linux-mm@kvack.org>; Sun, 23 Nov 2014 19:07:24 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id uj1si19114764pac.223.2014.11.23.19.07.20
        for <linux-mm@kvack.org>;
        Sun, 23 Nov 2014 19:07:23 -0800 (PST)
Date: Mon, 24 Nov 2014 12:10:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 7/7] mm/page_owner: correct owner information for
 early allocated pages
Message-ID: <20141124031017.GD10828@js1304-P5Q-DELUXE>
References: <1416557646-21755-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1416557646-21755-8-git-send-email-iamjoonsoo.kim@lge.com>
 <20141121153841.c15fa400fd5c76d3946523a8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141121153841.c15fa400fd5c76d3946523a8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 21, 2014 at 03:38:41PM -0800, Andrew Morton wrote:
> On Fri, 21 Nov 2014 17:14:06 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > Extended memory to store page owner information is initialized some time
> > later than that page allocator starts. Until initialization, many pages
> > can be allocated and they have no owner information. This make debugging
> > using page owner harder, so some fixup will be helpful.
> > 
> > This patch fix up this situation by setting fake owner information
> > immediately after page extension is initialized. Information doesn't
> > tell the right owner, but, at least, it can tell whether page is
> > allocated or not, more correctly.
> > 
> > On my testing, this patch catches 13343 early allocated pages, although
> > they are mostly allocated from page extension feature. Anyway, after then,
> > there is no page left that it is allocated and has no page owner flag.
> 
> We really should have a Documentation/vm/page_owner.txt which explains
> all this stuff, provides examples, etc.

Okay. Will do in next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
