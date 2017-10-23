Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE646B0253
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:04:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z80so15661370pff.11
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 00:04:40 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m18si4942016pfj.4.2017.10.23.00.04.38
        for <linux-mm@kvack.org>;
        Mon, 23 Oct 2017 00:04:39 -0700 (PDT)
Date: Mon, 23 Oct 2017 16:04:33 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v2 4/4] lockdep: Assign a lock_class per gendisk used for
 wait_for_completion()
Message-ID: <20171023070433.GJ3310@X58A-UD3R>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
 <1508396607-25362-1-git-send-email-byungchul.park@lge.com>
 <1508396607-25362-5-git-send-email-byungchul.park@lge.com>
 <20171020144451.GA16793@infradead.org>
 <20171022235334.GH3310@X58A-UD3R>
 <20171023063630.GA21280@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171023063630.GA21280@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, idryomov@gmail.com, kernel-team@lge.com

On Sun, Oct 22, 2017 at 11:36:30PM -0700, Christoph Hellwig wrote:
> On Mon, Oct 23, 2017 at 08:53:35AM +0900, Byungchul Park wrote:
> > On Fri, Oct 20, 2017 at 07:44:51AM -0700, Christoph Hellwig wrote:
> > > The Subject prefix for this should be "block:".
> > > 
> > > > @@ -945,7 +945,7 @@ int submit_bio_wait(struct bio *bio)
> > > >  {
> > > >  	struct submit_bio_ret ret;
> > > >  
> > > > -	init_completion(&ret.event);
> > > > +	init_completion_with_map(&ret.event, &bio->bi_disk->lockdep_map);
> > > 
> > > FYI, I have an outstanding patch to simplify this a lot, which
> > > switches this to DECLARE_COMPLETION_ONSTACK.  I can delay this or let
> > > you pick it up with your series, but we'll need a variant of
> > > DECLARE_COMPLETION_ONSTACK with the lockdep annotations.
> > 
> > Hello,
> > 
> > I'm sorry for late.
> > 
> > I think your patch makes block code simpler and better. I like it.
> > 
> > But, I just wonder if it's related to my series.
> 
> Because it shows that we also need a version of DECLARE_COMPLETION_ONSTACK
> the gets passed an explicit lockdep map.  And because if it was merged
> through a different tree it would create a conflict.
> 
> > Is it proper to add
> > your patch into my series?
> 
> Sure.

I will add yours at the next spin.

Thank you.

BTW, to all...

Any additional opinions about these patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
