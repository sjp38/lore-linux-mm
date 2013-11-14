Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4266B0044
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 23:01:04 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id p10so1391420pdj.37
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 20:01:03 -0800 (PST)
Received: from psmtp.com ([74.125.245.174])
        by mx.google.com with SMTP id hb3si26338403pac.210.2013.11.13.20.01.02
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 20:01:03 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id v10so1395976pde.11
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 20:01:01 -0800 (PST)
Date: Wed, 13 Nov 2013 20:00:34 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] staging: zsmalloc: Ensure handle is never 0 on success
In-Reply-To: <20131112154137.GA3330@gmail.com>
Message-ID: <alpine.LNX.2.00.1311131811030.1120@eggly.anvils>
References: <20131107070451.GA10645@bbox> <20131112154137.GA3330@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, lliubbo@gmail.com, jmarchan@redhat.com, mgorman@suse.de, riel@redhat.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Luigi Semenzato <semenzato@google.com>

On Wed, 13 Nov 2013, Minchan Kim wrote:
> On Thu, Nov 07, 2013 at 04:04:51PM +0900, Minchan Kim wrote:
> > On Wed, Nov 06, 2013 at 07:05:11PM -0800, Greg KH wrote:
> > > On Wed, Nov 06, 2013 at 03:46:19PM -0800, Nitin Gupta wrote:
> > >  > I'm getting really tired of them hanging around in here for many years
> > > > > now...
> > > > >
> > > > 
> > > > Minchan has tried many times to promote zram out of staging. This was
> > > > his most recent attempt:
> > > > 
> > > > https://lkml.org/lkml/2013/8/21/54
...
> 
> Hello Andrew,
> 
> I'd like to listen your opinion.
> 
> The zram promotion trial started since Aug 2012 and I already have get many
> Acked/Reviewed feedback and positive feedback from Rik and Bob in this thread.
> (ex, Jens Axboe[1], Konrad Rzeszutek Wilk[2], Nitin Gupta[3], Pekka Enberg[4])
> In Linuxcon, Hugh gave positive feedback about zram(Hugh, If I misunderstood,
> please correct me!). And there are lots of users already in embedded industry
> ex, (most of TV in the world, Chromebook, CyanogenMod, Android Kitkat.)
> They are not idiot. Zram is really effective for embedded world.

Sorry for taking so long to respond, Minchan: no, you do not misrepresent
me at all.  Promotion of zram and zsmalloc from staging is way overdue:
they long ago proved their worth, look tidy, and have an active maintainer.

Putting them into drivers/staging was always a mistake, and I quite
understand Greg's impatience with them by now; but please let's move
them to where they belong instead of removing them.

I would not have lent support to zswap if I'd thought that was going to
block zram.  And I was not the only one surprised when zswap replaced its
use of zsmalloc by zbud: we had rather expected a zbud option to be added,
and I still assume that zsmalloc support will be added back to zswap later.

I think your August 2013 posting moved zsmalloc under zram and moved it
all to drivers/block?  That is the right place for zram, but I do think
zsmalloc.c (I'm not very keen on _drvs and -mains myself) should be
alongside zbud.c in mm, where we can better keep an eye on its
struct-pageyness.

IMHO
Hugh

> 
> We spent much time with preventing zram enhance since it have been in staging
> and Greg never want to improve without promotion.
> 
> Please consider promotion and let us improve it.
> I think only remained thing is your decision.
> 
> 
> 1. https://lkml.org/lkml/2012/9/11/551
> 2. https://lkml.org/lkml/2012/8/9/636
> 3. https://lkml.org/lkml/2012/8/8/390
> 4. https://lkml.org/lkml/2012/9/26/126

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
