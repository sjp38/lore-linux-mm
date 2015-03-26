Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 99AC16B006E
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:13:06 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so55701621pdn.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 01:13:06 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id qj4si7249504pbc.154.2015.03.26.01.13.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 01:13:05 -0700 (PDT)
Received: by pdbcz9 with SMTP id cz9so55470443pdb.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 01:13:05 -0700 (PDT)
Date: Thu, 26 Mar 2015 17:13:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [withdrawn]
 zsmalloc-remove-extra-cond_resched-in-__zs_compact.patch removed from -mm
 tree
Message-ID: <20150326081313.GB1669@swordfish>
References: <5513199f.t25SPuX5ULuM6JS8%akpm@linux-foundation.org>
 <20150326002717.GA1669@swordfish>
 <20150326073916.GB26725@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326073916.GB26725@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, sfr@canb.auug.org.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (03/26/15 16:39), Minchan Kim wrote:
> Hello Sergey,
> 
> Sorry for slow response.
> I am overwhelmed with too much to do. :(
> 

Hello,
sure, no problem.

> > > diff -puN mm/zsmalloc.c~zsmalloc-remove-extra-cond_resched-in-__zs_compact mm/zsmalloc.c
> > > --- a/mm/zsmalloc.c~zsmalloc-remove-extra-cond_resched-in-__zs_compact
> > > +++ a/mm/zsmalloc.c
> > > @@ -1717,8 +1717,6 @@ static unsigned long __zs_compact(struct
> > >  	struct page *dst_page = NULL;
> > >  	unsigned long nr_total_migrated = 0;
> > >  
> > > -	cond_resched();
> > > -
> > >  	spin_lock(&class->lock);
> > >  	while ((src_page = isolate_source_page(class))) {

> 
> If we removed cond_resched out of outer loop(ie, your patch), we lose
> the chance to reschedule if alloc_target_page fails(ie, there is no
> zspage in ZS_ALMOST_FULL and ZS_ALMOST_EMPTY).


in outer loop we have preemption enabled and unlocked class. wouldn't that help?
(hm, UP system?)

> It might be not rare event if we does compation successfully for a
> size_class. However, with next coming higher size_class for __zs_compact,
> we will encounter cond_resched during compaction.
> So, I am happy to ack. :)
> 
> Acked-by: Minchan Kim <minchan@kernel.org>

thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
