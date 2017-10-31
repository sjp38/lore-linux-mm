Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1005C6B026B
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:34:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d28so14458616pfe.1
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 03:34:57 -0700 (PDT)
Received: from BJEXCAS004.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id j21si1268657pgn.484.2017.10.31.03.34.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 03:34:56 -0700 (PDT)
Date: Tue, 31 Oct 2017 18:34:53 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: Re: [PATCH 4/4] block: add WARN_ON if bdi register fail
Message-ID: <20171031103453.GC1616@source.didichuxing.com>
References: <cover.1509038624.git.zhangweiping@didichuxing.com>
 <413b04ba6a2a0b03b0cb3c578865d71b2ef97921.1509038624.git.zhangweiping@didichuxing.com>
 <20171030131430.GJ23278@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171030131430.GJ23278@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 30, 2017 at 02:14:30PM +0100, Jan Kara wrote:
> On Fri 27-10-17 01:36:42, weiping zhang wrote:
> > device_add_disk need do more safety error handle, so this patch just
> > add WARN_ON.
> > 
> > Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
> > ---
> >  block/genhd.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/block/genhd.c b/block/genhd.c
> > index dd305c65ffb0..cb55eea821eb 100644
> > --- a/block/genhd.c
> > +++ b/block/genhd.c
> > @@ -660,7 +660,9 @@ void device_add_disk(struct device *parent, struct gendisk *disk)
> >  
> >  	/* Register BDI before referencing it from bdev */
> >  	bdi = disk->queue->backing_dev_info;
> > -	bdi_register_owner(bdi, disk_to_dev(disk));
> > +	retval = bdi_register_owner(bdi, disk_to_dev(disk));
> > +	if (retval)
> > +		WARN_ON(1);
> 
> Just a nit: You can do
> 
> 	WARN_ON(retval);
> 
> Otherwise you can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
more claner, I'll apply at V2, Thanks

--
weiping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
