Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE6C6B0253
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 21:58:08 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t10so5431751pgo.20
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 18:58:08 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f6si143143plf.94.2017.10.18.18.58.06
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 18:58:07 -0700 (PDT)
Date: Thu, 19 Oct 2017 10:57:55 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [RESEND PATCH 3/3] lockdep: Assign a lock_class per gendisk used
 for wait_for_completion()
Message-ID: <20171019015755.GE32368@X58A-UD3R>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
 <1508319532-24655-4-git-send-email-byungchul.park@lge.com>
 <20171018095916.gr3n4mal6dz5xs7v@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018095916.gr3n4mal6dz5xs7v@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

On Wed, Oct 18, 2017 at 11:59:16AM +0200, Ingo Molnar wrote:
> 
> * Byungchul Park <byungchul.park@lge.com> wrote:
> 
> > diff --git a/block/bio.c b/block/bio.c
> > index 9a63597..0d4d6c0 100644
> > --- a/block/bio.c
> > +++ b/block/bio.c
> > @@ -941,7 +941,7 @@ int submit_bio_wait(struct bio *bio)
> >  {
> >  	struct submit_bio_ret ret;
> >  
> > -	init_completion(&ret.event);
> > +	init_completion_with_map(&ret.event, &bio->bi_disk->lockdep_map);
> >  	bio->bi_private = &ret;
> >  	bio->bi_end_io = submit_bio_wait_endio;
> >  	bio->bi_opf |= REQ_SYNC;
> > @@ -1382,7 +1382,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
> >  
> >  			if (len <= 0)
> >  				break;
> > -			
> > +
> >  			if (bytes > len)
> >  				bytes = len;
> >  
> 
> That's a spurious cleanup unrelated to this patch.

I will separate it. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
