Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 021046B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:07:16 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id n4so9272463qaq.12
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:07:15 -0800 (PST)
Received: from smtp.variantweb.net (smtp.variantweb.net. [104.131.104.118])
        by mx.google.com with ESMTPS id hj6si23874226qcb.49.2015.01.12.12.07.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 12:07:14 -0800 (PST)
Date: Mon, 12 Jan 2015 14:07:11 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH v2] mm/zsmalloc: add statistics support
Message-ID: <20150112200711.GA17340@cerebellum.variantweb.net>
References: <20141219154548.3aa4cc02b3322f926aa4c1d6@linux-foundation.org>
 <20141219235852.GB11975@blaptop>
 <20141219160648.5cea8a6b0c764caa6100a585@linux-foundation.org>
 <20141220001043.GC11975@blaptop>
 <20141219161756.bcf7421acb4bc7a286c1afa3@linux-foundation.org>
 <20141220002303.GD11975@blaptop>
 <CADAEsF-=RwwR2D_LzhVYKhfmfPCsQE73bJYyH=tjn4BtHVrdew@mail.gmail.com>
 <20141220022557.GA19822@blaptop>
 <CADAEsF-Rtc00hP9Dd-Lx2pq9panQFyoUEi9U7eO1SOW6-zWJvw@mail.gmail.com>
 <20141223024045.GA30174@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141223024045.GA30174@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>

On Tue, Dec 23, 2014 at 11:40:45AM +0900, Minchan Kim wrote:
> Hi Ganesh,
> 
> On Tue, Dec 23, 2014 at 10:26:12AM +0800, Ganesh Mahendran wrote:
> > Hello Minchan
> > 
> > 2014-12-20 10:25 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > > Hey Ganesh,
> > >
> > > On Sat, Dec 20, 2014 at 09:43:34AM +0800, Ganesh Mahendran wrote:
> > >> 2014-12-20 8:23 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > >> > On Fri, Dec 19, 2014 at 04:17:56PM -0800, Andrew Morton wrote:
> > >> >> On Sat, 20 Dec 2014 09:10:43 +0900 Minchan Kim <minchan@kernel.org> wrote:
> > >> >>
> > >> >> > > It involves rehashing a lengthy argument with Greg.
> > >> >> >
> > >> >> > Okay. Then, Ganesh,
> > >> >> > please add warn message about duplicaed name possibility althoug
> > >> >> > it's unlikely as it is.
> > >> >>
> > >> >> Oh, getting EEXIST is easy with this patch.  Just create and destroy a
> > >> >> pool 2^32 times and the counter wraps ;) It's hardly a serious issue
> > >> >> for a debugging patch.
> > >> >
> > >> > I meant that I wanted to change from index to name passed from caller like this
> > >> >
> > >> > zram:
> > >> >         zs_create_pool(GFP_NOIO | __GFP_HIGHMEM, zram->disk->first_minor);
> > >> >
> > >> > So, duplication should be rare. :)
> > >>
> > >> We still can not know whether the name is duplicated if we do not
> > >> change the debugfs API.
> > >> The API does not return the errno to us.
> > >>
> > >> How about just zsmalloc decides the name of the pool-id, like pool-x.
> > >> When the pool-id reaches
> > >> 0xffff.ffff, we print warn message about duplicated name, and stop
> > >> creating the debugfs entry
> > >> for the user.
> > >
> > > The idea is from the developer point of view to implement thing easy
> > > but my point is we should take care of user(ie, admin) rather than
> > > developer(ie, we).
> > 
> > Yes. I got it.
> > 
> > >
> > > For user, /sys/kernel/debug/zsmalloc/zram0 would be more
> > > straightforward and even it doesn't need zram to export
> > > /sys/block/zram0/pool-id.
> > 
> > BTW, If we add a new argument in zs_create_pool(). It seems we also need to
> > add argument in zs_zpool_create(). So, zpool/zswap/zbud will be
> > modified to support
> > the new API.
> > Is that acceptable?
> 
> I think it's doable.
> The zpool_create_pool has already zswap_zpool_type.
> Ccing maintainers for double check.

Late response, but fine by me.

Seth

> 
> Many thanks.
> 
> 
> > 
> > Thanks.
> > 
> > >
> > > Thanks.
> > >
> > >>
> > >> Thanks.
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
