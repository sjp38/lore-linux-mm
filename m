Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EC9506B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 22:34:56 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so81626176pdb.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 19:34:56 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id yi7si798926pbc.190.2015.03.26.19.34.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 19:34:56 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so81360193pac.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 19:34:56 -0700 (PDT)
Date: Fri, 27 Mar 2015 11:34:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [withdrawn]
 zsmalloc-remove-extra-cond_resched-in-__zs_compact.patch removed from -mm
 tree
Message-ID: <20150327023448.GC26725@blaptop>
References: <5513199f.t25SPuX5ULuM6JS8%akpm@linux-foundation.org>
 <20150326002717.GA1669@swordfish>
 <20150326073916.GB26725@blaptop>
 <20150326081313.GB1669@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326081313.GB1669@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, sfr@canb.auug.org.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 26, 2015 at 05:13:13PM +0900, Sergey Senozhatsky wrote:
> On (03/26/15 16:39), Minchan Kim wrote:
> > Hello Sergey,
> > 
> > Sorry for slow response.
> > I am overwhelmed with too much to do. :(
> > 
> 
> Hello,
> sure, no problem.
> 
> > > > diff -puN mm/zsmalloc.c~zsmalloc-remove-extra-cond_resched-in-__zs_compact mm/zsmalloc.c
> > > > --- a/mm/zsmalloc.c~zsmalloc-remove-extra-cond_resched-in-__zs_compact
> > > > +++ a/mm/zsmalloc.c
> > > > @@ -1717,8 +1717,6 @@ static unsigned long __zs_compact(struct
> > > >  	struct page *dst_page = NULL;
> > > >  	unsigned long nr_total_migrated = 0;
> > > >  
> > > > -	cond_resched();
> > > > -
> > > >  	spin_lock(&class->lock);
> > > >  	while ((src_page = isolate_source_page(class))) {
> 
> > 
> > If we removed cond_resched out of outer loop(ie, your patch), we lose
> > the chance to reschedule if alloc_target_page fails(ie, there is no
> > zspage in ZS_ALMOST_FULL and ZS_ALMOST_EMPTY).
> 
> 
> in outer loop we have preemption enabled and unlocked class. wouldn't that help?
> (hm, UP system?)

It depends on preemption model. If you enable full preemption, you are right
but if you enable just voluntary preemption, cond_resched will help latency.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
