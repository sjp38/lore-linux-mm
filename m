Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8E8D6B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 01:59:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a190so856984280pgc.0
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 22:59:37 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h67si52438216pgc.72.2016.12.28.22.59.36
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 22:59:37 -0800 (PST)
Date: Thu, 29 Dec 2016 15:59:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: mm: fix typo of cache_alloc_zspage()
Message-ID: <20161229065935.GE1815@bbox>
References: <58646FB7.2040502@huawei.com>
 <20161229064457.GD1815@bbox>
 <20161229065205.GA3892@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161229065205.GA3892@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, ngupta@vflare.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Sergey,

On Thu, Dec 29, 2016 at 03:52:05PM +0900, Sergey Senozhatsky wrote:
> On (12/29/16 15:44), Minchan Kim wrote:
> > On Thu, Dec 29, 2016 at 10:06:47AM +0800, Xishi Qiu wrote:
> > > Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> > > ---
> > >  mm/zsmalloc.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > > index 9cc3c0b..2d6c92e 100644
> > > --- a/mm/zsmalloc.c
> > > +++ b/mm/zsmalloc.c
> > > @@ -364,7 +364,7 @@ static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
> > >  {
> > >  	return kmem_cache_alloc(pool->zspage_cachep,
> > >  			flags & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
> > > -};
> > > +}
> > 
> > Although it's trivial, we need descritpion.
> > Please, could you resend to Andrew Morton with filling description?
> 
> I don't know... do we want to have it as a separate patch?
> may be we can fold it into some other patch someday later.

Xishi spent his time to make the patch(review,create/send). And I want to
give a credit to him. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
