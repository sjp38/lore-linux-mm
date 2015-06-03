Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2E727900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 23:55:46 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so147357743pdb.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 20:55:45 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id ai4si29153759pbc.176.2015.06.02.20.55.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 20:55:45 -0700 (PDT)
Received: by padj3 with SMTP id j3so81375973pad.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 20:55:45 -0700 (PDT)
Date: Wed, 3 Jun 2015 12:56:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] MAINTAINERS: add zpool
Message-ID: <20150603035608.GA1652@swordfish>
References: <1433264166-31452-1-git-send-email-ddstreet@ieee.org>
 <1433279395.4861.100.camel@perches.com>
 <CALZtONBVobxH--GGGdJaETScMorHKCY5ferHct74B79QDNDb4w@mail.gmail.com>
 <1433280616.4861.102.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433280616.4861.102.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/02/15 14:30), Joe Perches wrote:
> > >> +ZPOOL COMPRESSED PAGE STORAGE API
> > >> +M:   Dan Streetman <ddstreet@ieee.org>
> > >> +L:   linux-mm@kvack.org
> > >> +S:   Maintained
> > >> +F:   mm/zpool.c
> > >> +F:   include/linux/zpool.h
> > >
> > > If zpool.h is only included from files in mm/,
> > > maybe zpool.h should be moved to mm/ ?
> > 
> > It *could* be included by others, e.g. drivers/block/zram.
> > 
> > It currently is only used by zswap though, so yeah it could be moved
> > to mm/.  Should I move it there, until (if ever) anyone outside of mm/
> > wants to use it?
> 
> Up to you.
> 
> I think include/linux is a bit overstuffed and
> whatever can be include local should be.
> 

Hi,

I agree, can be local for now. if zram will ever want to use zpool
then we will move zpool.h to include/linux. just my 5 cents.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
