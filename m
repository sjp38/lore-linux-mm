Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id EDE316B0071
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 04:58:26 -0400 (EDT)
Received: by padev16 with SMTP id ev16so102486642pad.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 01:58:26 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id bz4si63431480pab.196.2015.06.29.01.58.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 01:58:26 -0700 (PDT)
Received: by pdbci14 with SMTP id ci14so113272897pdb.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 01:58:25 -0700 (PDT)
Date: Mon, 29 Jun 2015 17:58:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCHv3 4/7] zsmalloc: introduce zs_can_compact() function
Message-ID: <20150629085853.GB549@swordfish>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-5-git-send-email-sergey.senozhatsky@gmail.com>
 <20150629064546.GB13179@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150629064546.GB13179@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/29/15 15:45), Minchan Kim wrote:
[..]
> > +/*
> > + * Make sure that we actually can compact this class,
> > + * IOW if migration will release at least one szpage.
> 
>                                                  zspage,

ok.

> > + *
> > + * Should be called under class->lock
> 
> Please comment about return.

ok.

> > + */
> > +static unsigned long zs_can_compact(struct size_class *class)
> > +{
> > +	/*
> > +	 * Calculate how many unused allocated objects we
> > +	 * have and see if we can free any zspages. Otherwise,
> > +	 * compaction can just move objects back and forth w/o
> > +	 * any memory gain.
> > +	 */
> > +	unsigned long obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
> > +		zs_stat_get(class, OBJ_USED);
> > +
> 
> I want to check one more thing.
> 
> We could have lots of ZS_ALMOST_FULL but no ZS_ALMOST_EMPTY.
> In this implementation, compaction cannot have a source so
> it would better to bail out.
> IOW,
> 
>       if (!zs_stat_get(class, CLASS_ALMOST_EMPTY))
>               return 0;

ok.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
