Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1778D6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 00:51:23 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so21819717pdj.36
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 21:51:23 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id fo17si2283524pac.161.2014.08.25.21.51.21
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 21:51:23 -0700 (PDT)
Date: Tue, 26 Aug 2014 13:52:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 3/4] zram: zram memory size limitation
Message-ID: <20140826045214.GE11319@bbox>
References: <1408925156-11733-1-git-send-email-minchan@kernel.org>
 <1408925156-11733-4-git-send-email-minchan@kernel.org>
 <20140825110927.GB933@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140825110927.GB933@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, ds2horner@gmail.com

Hey Sergey,

On Mon, Aug 25, 2014 at 08:09:27PM +0900, Sergey Senozhatsky wrote:
> On (08/25/14 09:05), Minchan Kim wrote:
> > Since zram has no control feature to limit memory usage,
> > it makes hard to manage system memrory.
> > 
> > This patch adds new knob "mem_limit" via sysfs to set up the
> > a limit so that zram could fail allocation once it reaches
> > the limit.
> > 
> > In addition, user could change the limit in runtime so that
> > he could manage the memory more dynamically.
> > 
> > Initial state is no limit so it doesn't break old behavior.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  Documentation/ABI/testing/sysfs-block-zram | 10 ++++++++
> >  Documentation/blockdev/zram.txt            | 24 ++++++++++++++---
> >  drivers/block/zram/zram_drv.c              | 41 ++++++++++++++++++++++++++++++
> >  drivers/block/zram/zram_drv.h              |  5 ++++
> >  4 files changed, 76 insertions(+), 4 deletions(-)
> > 
> > diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
> > index 70ec992514d0..dbe643775ec1 100644
> > --- a/Documentation/ABI/testing/sysfs-block-zram
> > +++ b/Documentation/ABI/testing/sysfs-block-zram
> > @@ -119,3 +119,13 @@ Description:
> >  		efficiency can be calculated using compr_data_size and this
> >  		statistic.
> >  		Unit: bytes
> > +
> > +What:		/sys/block/zram<id>/mem_limit
> > +Date:		August 2014
> > +Contact:	Minchan Kim <minchan@kernel.org>
> > +Description:
> > +		The mem_limit file is read/write and specifies the amount
> > +		of memory to be able to consume memory to store store
> > +		compressed data. The limit could be changed in run time
> > +		and "0" means disable the limit. No limit is the initial state.
> 
> just a nitpick, sorry.
> "the amount of memory to be able to consume memory to store store compressed data"
> 							^^^^^^^
> 
> "the maximum amount of memory ZRAM can use to store the compressed data"?

Will fix.
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
