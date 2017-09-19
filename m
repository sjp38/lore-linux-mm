Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 366F76B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 06:32:11 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id o200so6782473itg.2
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 03:32:11 -0700 (PDT)
Received: from BJEXCAS002.didichuxing.com ([36.110.17.22])
        by mx.google.com with ESMTPS id x1si1224965ite.192.2017.09.19.03.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Sep 2017 03:32:09 -0700 (PDT)
Date: Tue, 19 Sep 2017 18:31:39 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: Re: [PATCH] bdi: fix cleanup when fail to percpu_counter_init
Message-ID: <20170919103139.GA1553@localhost.didichuxing.com>
References: <20170915182700.GA2489@localhost.didichuxing.com>
 <21c323b8-7ec4-518f-5fe5-3ed724506c31@kernel.dk>
 <20170919081331.GB3216@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170919081331.GB3216@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>, tj@kernel.org, linux-mm@kvack.org

On Tue, Sep 19, 2017 at 10:13:31AM +0200, Jan Kara wrote:
> On Mon 18-09-17 08:04:04, Jens Axboe wrote:
> > On 09/15/2017 12:27 PM, weiping zhang wrote:
> > > when percpu_counter_init fail at i, 0 ~ (i-1) should be destoried, not
> > > 1 ~ i.
> > > 
> > > Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
> > > ---
> > >  mm/backing-dev.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > > index e19606b..d399d3c 100644
> > > --- a/mm/backing-dev.c
> > > +++ b/mm/backing-dev.c
> > > @@ -334,7 +334,7 @@ static int wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi,
> > >  	return 0;
> > >  
> > >  out_destroy_stat:
> > > -	while (i--)
> > > +	while (--i >= 0)
> > 
> > These two constructs will produce identical results.
> 
> Bah, you are correct. I got confused.
> 

It's my fault, thanks all of you, ^_^

weiping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
