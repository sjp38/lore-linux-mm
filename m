Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 406A86B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 10:50:27 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so4110591wre.10
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 07:50:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22si1281488edm.479.2017.11.30.07.50.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 07:50:25 -0800 (PST)
Date: Thu, 30 Nov 2017 16:48:25 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v2 03/11] lib: make the fprop batch size a multiple of
 PAGE_SIZE
Message-ID: <20171130154825.GK3553@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
 <1511385366-20329-4-git-send-email-josef@toxicpanda.com>
 <20171129170443.GC28256@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129170443.GC28256@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wed, Nov 29, 2017 at 06:04:43PM +0100, Jan Kara wrote:
> On Wed 22-11-17 16:15:58, Josef Bacik wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > We are converting the writeback counters to use bytes instead of pages,
> > so we need to make the batch size for the percpu modifications align
> > properly with the new units.  Since we used pages before, just multiply
> > by PAGE_SIZE to get the equivalent bytes for the batch size.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> 
> Looks good to me, just please make this part of patch 5/11. Otherwise
> bisection may get broken by too large errors in per-cpu counters of IO
> completions... Thanks!
> 
> 								Honza
> 
> > ---
> >  lib/flex_proportions.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
> > index 2cc1f94e03a1..b0343ae71f5e 100644
> > --- a/lib/flex_proportions.c
> > +++ b/lib/flex_proportions.c
> > @@ -166,7 +166,7 @@ void fprop_fraction_single(struct fprop_global *p,
> >  /*
> >   * ---- PERCPU ----
> >   */
> > -#define PROP_BATCH (8*(1+ilog2(nr_cpu_ids)))
> > +#define PROP_BATCH (8*PAGE_SIZE*(1+ilog2(nr_cpu_ids)))

So when the patch is going to be updated, please fix the coding style here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
