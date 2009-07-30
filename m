Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC3F6B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 15:14:22 -0400 (EDT)
Date: Thu, 30 Jul 2009 21:12:14 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/5] mm: Add kmalloc NULL tests
Message-ID: <20090730191213.GA9471@cmpxchg.org>
References: <Pine.LNX.4.64.0907301608350.8734@ask.diku.dk> <20090730153658.GA22986@cmpxchg.org> <20090730183558.GA11763@logfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20090730183558.GA11763@logfs.org>
Sender: owner-linux-mm@kvack.org
To: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Cc: Julia Lawall <julia@diku.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 30, 2009 at 08:35:59PM +0200, JA?rn Engel wrote:
> On Thu, 30 July 2009 17:36:58 +0200, Johannes Weiner wrote:
> > On Thu, Jul 30, 2009 at 04:10:22PM +0200, Julia Lawall wrote:
> > 
> > > diff --git a/mm/slab.c b/mm/slab.c
> > > index 7b5d4de..972e427 100644
> > > --- a/mm/slab.c
> > > +++ b/mm/slab.c
> > > @@ -1502,6 +1502,7 @@ void __init kmem_cache_init(void)
> > >  
> > >  		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
> > >  
> > > +		BUG_ON(!ptr);
> > >  		BUG_ON(cpu_cache_get(&cache_cache) != &initarray_cache.cache);
> > >  		memcpy(ptr, cpu_cache_get(&cache_cache),
> > >  		       sizeof(struct arraycache_init));
> > 
> > This does not change the end result when the allocation fails: you get
> > a stacktrace and a kernel panic.  Leaving it as is saves a line of
> > code.
> 
> According to http://lwn.net/Articles/342420/, there may be a subtle
> difference.

You will probably have a hard time establishing a userspace mapping
before slab is initializied :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
