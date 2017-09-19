Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7D886B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 04:13:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r74so3147105wme.5
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 01:13:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o91si8939164edb.106.2017.09.19.01.13.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Sep 2017 01:13:33 -0700 (PDT)
Date: Tue, 19 Sep 2017 10:13:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] bdi: fix cleanup when fail to percpu_counter_init
Message-ID: <20170919081331.GB3216@quack2.suse.cz>
References: <20170915182700.GA2489@localhost.didichuxing.com>
 <21c323b8-7ec4-518f-5fe5-3ed724506c31@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <21c323b8-7ec4-518f-5fe5-3ed724506c31@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: weiping zhang <zhangweiping@didichuxing.com>, jack@suse.cz, tj@kernel.org, linux-mm@kvack.org

On Mon 18-09-17 08:04:04, Jens Axboe wrote:
> On 09/15/2017 12:27 PM, weiping zhang wrote:
> > when percpu_counter_init fail at i, 0 ~ (i-1) should be destoried, not
> > 1 ~ i.
> > 
> > Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
> > ---
> >  mm/backing-dev.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index e19606b..d399d3c 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -334,7 +334,7 @@ static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi,
> >  	return 0;
> >  
> >  out_destroy_stat:
> > -	while (i--)
> > +	while (--i >= 0)
> 
> These two constructs will produce identical results.

Bah, you are correct. I got confused.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
