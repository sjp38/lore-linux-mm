Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C46BE280247
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 19:52:20 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id o29so9663029qto.12
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 16:52:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m129sor14576822qkc.153.2017.11.15.16.52.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 16:52:19 -0800 (PST)
Date: Wed, 15 Nov 2017 19:52:18 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH] mm: use sc->priority for slab shrink targets
Message-ID: <20171116005217.jtm3rh7l65bfhhfb@destiny>
References: <1510766070-4772-1-git-send-email-josef@toxicpanda.com>
 <20171115154826.45d70959f630ac7508d8d36e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115154826.45d70959f630ac7508d8d36e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <josef@toxicpanda.com>, kernel-team@fb.com, linux-mm@kvack.org, Josef Bacik <jbacik@fb.com>

On Wed, Nov 15, 2017 at 03:48:26PM -0800, Andrew Morton wrote:
> On Wed, 15 Nov 2017 12:14:30 -0500 Josef Bacik <josef@toxicpanda.com> wrote:
> 
> > Previously we were using the ratio of the number of lru pages scanned to
> > the number of eligible lru pages to determine the number of slab objects
> > to scan.  The problem with this is that these two things have nothing to
> > do with each other, so in slab heavy work loads where there is little to
> > no page cache we can end up with the pages scanned being a very low
> > number.  This means that we reclaim next to no slab pages and waste a
> > lot of time reclaiming small amounts of space.
> > 
> > ...
> >
> > Andrew, I noticed you hadn't picked this up yet, so I rebased it on the latest
> > linus and updated the ack's, it should be good to go.
> 
> I dropped a previous version of this on Oct 3 due to runtime failures
> (I think).  What were those and how does this patch fix them (if it
> does?)
> 

I went back and looked and you said it didn't apply cleanly, but then I rebased
it and it applied fine, so I was confused.  What I _think_ happened is Johannes
added a cleanup patch in the thread that didn't apply cleanly so you didn't
apply either of them.  I'll dig out Johannes patch in the morning and clean it
up and send it along as well.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
