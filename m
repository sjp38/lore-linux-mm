Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B63446B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 01:51:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so947630334pgi.2
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 22:51:57 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 59si52549016plp.46.2016.12.28.22.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 22:51:57 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id i5so18034170pgh.2
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 22:51:56 -0800 (PST)
Date: Thu, 29 Dec 2016 15:52:05 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: mm: fix typo of cache_alloc_zspage()
Message-ID: <20161229065205.GA3892@jagdpanzerIV.localdomain>
References: <58646FB7.2040502@huawei.com>
 <20161229064457.GD1815@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161229064457.GD1815@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On (12/29/16 15:44), Minchan Kim wrote:
> On Thu, Dec 29, 2016 at 10:06:47AM +0800, Xishi Qiu wrote:
> > Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> > ---
> >  mm/zsmalloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 9cc3c0b..2d6c92e 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -364,7 +364,7 @@ static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
> >  {
> >  	return kmem_cache_alloc(pool->zspage_cachep,
> >  			flags & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
> > -};
> > +}
> 
> Although it's trivial, we need descritpion.
> Please, could you resend to Andrew Morton with filling description?

I don't know... do we want to have it as a separate patch?
may be we can fold it into some other patch someday later.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
