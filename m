Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id ADD966B00DC
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 01:38:20 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so13742704pdj.24
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 22:38:20 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id qy8si24666729pbb.218.2014.11.12.22.38.18
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 22:38:19 -0800 (PST)
Date: Thu, 13 Nov 2014 15:40:35 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/5] mm/page_ext: resurrect struct page extending
 code for debugging
Message-ID: <20141113064035.GB18369@js1304-P5Q-DELUXE>
References: <1415780835-24642-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1415780835-24642-2-git-send-email-iamjoonsoo.kim@lge.com>
 <54638BE4.3080509@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54638BE4.3080509@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Alexander Nyberg <alexn@dsv.su.se>, Dave Hansen <dave@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 12, 2014 at 08:33:40AM -0800, Dave Hansen wrote:
> On 11/12/2014 12:27 AM, Joonsoo Kim wrote:
> > @@ -1092,6 +1096,14 @@ struct mem_section {
> >  
> >  	/* See declaration of similar field in struct zone */
> >  	unsigned long *pageblock_flags;
> > +#ifdef CONFIG_PAGE_EXTENSION
> > +	/*
> > +	 * If !SPARSEMEM, pgdat doesn't have page_ext pointer. We use
> > +	 * section. (see page_ext.h about this.)
> > +	 */
> > +	struct page_ext *page_ext;
> > +	unsigned long pad;
> > +#endif
> 
> Will the distributions be amenable to enabling this?  If so, I'm all for
> it if it gets us things like page_owner at runtime.

Yes, I hope so.
At least, I can make it default to our product. But, how distributions
will do is beyond my power. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
