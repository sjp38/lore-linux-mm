Subject: Re: [RFC 2/4] CONFIG_STABLE: Switch off kmalloc(0) tests in slab allocators
References: <20070531002047.702473071@sgi.com>
	<20070531003012.532539202@sgi.com>
	<20070531195133.GK5488@mami.zabbo.net>
From: Andi Kleen <andi@firstfloor.org>
Date: 01 Jun 2007 00:37:48 +0200
In-Reply-To: <20070531195133.GK5488@mami.zabbo.net>
Message-ID: <p736468d3gj.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Brown <zach.brown@oracle.com>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Zach Brown <zach.brown@oracle.com> writes:

> > +#ifndef CONFIG_STABLE
> >  	/*
> >  	 * We should return 0 if size == 0 (which would result in the
> >  	 * kmalloc caller to get NULL) but we use the smallest object
> > @@ -81,6 +82,7 @@ static inline int kmalloc_index(size_t s
> >  	 * we can discover locations where we do 0 sized allocations.
> >  	 */
> >  	WARN_ON_ONCE(size == 0);
> > +#endif
> 
> > +#ifndef CONFIG_STABLE
> >  	WARN_ON_ONCE(size == 0);
> > +#endif
> 
> I wonder if there wouldn't be value in making a WARN_*() variant that
> contained the ifdef internally so we could lose these tedious
> surrounding ifdefs in call sites.  WARN_DEVELOPER_WHEN(), or something.
> I don't care what it's called.  

Networking has had NETDEBUG(codeblock) for this. Perhaps something
similar would be useful (DEVELOPMENT(codeblock)) in addition
to the special WARN/BUG_ONs

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
