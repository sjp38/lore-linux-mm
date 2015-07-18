Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id CDCEE280344
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 20:54:11 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so69307631pdr.2
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 17:54:11 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id ki10si21046222pbc.218.2015.07.17.17.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 17:54:10 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so69306742pdr.2
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 17:54:05 -0700 (PDT)
Date: Sat, 18 Jul 2015 09:53:10 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: do not take class lock in
 zs_shrinker_count()
Message-ID: <20150718005310.GA638@swordfish>
References: <1437131898-2231-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150717224233.GA7334@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150717224233.GA7334@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hi,

On (07/18/15 07:42), Minchan Kim wrote:
> I asked to remove the comment of zs_can_compact about lock.
> "Should be called under class->lock."

Oh... I somehow quickly read it and thought you were talking
about the commit message. Fixed and resent.

> Otherwise,
> 
> Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

	-ss

> > ---
> >  mm/zsmalloc.c | 2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 1edd8a0..ed64cf5 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1836,9 +1836,7 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
> >  		if (class->index != i)
> >  			continue;
> >  
> > -		spin_lock(&class->lock);
> >  		pages_to_free += zs_can_compact(class);
> > -		spin_unlock(&class->lock);
> >  	}
> >  
> >  	return pages_to_free;
> > -- 
> > 2.4.6
> > 
> 
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
