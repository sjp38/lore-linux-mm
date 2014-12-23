Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 537E46B0032
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 21:39:07 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so6938153pdb.32
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 18:39:07 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id oy3si6824959pdb.34.2014.12.22.18.39.04
        for <linux-mm@kvack.org>;
        Mon, 22 Dec 2014 18:39:05 -0800 (PST)
Date: Tue, 23 Dec 2014 11:40:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: add statistics support
Message-ID: <20141223024045.GA30174@bbox>
References: <20141219233937.GA11975@blaptop>
 <20141219154548.3aa4cc02b3322f926aa4c1d6@linux-foundation.org>
 <20141219235852.GB11975@blaptop>
 <20141219160648.5cea8a6b0c764caa6100a585@linux-foundation.org>
 <20141220001043.GC11975@blaptop>
 <20141219161756.bcf7421acb4bc7a286c1afa3@linux-foundation.org>
 <20141220002303.GD11975@blaptop>
 <CADAEsF-=RwwR2D_LzhVYKhfmfPCsQE73bJYyH=tjn4BtHVrdew@mail.gmail.com>
 <20141220022557.GA19822@blaptop>
 <CADAEsF-Rtc00hP9Dd-Lx2pq9panQFyoUEi9U7eO1SOW6-zWJvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CADAEsF-Rtc00hP9Dd-Lx2pq9panQFyoUEi9U7eO1SOW6-zWJvw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

Hi Ganesh,

On Tue, Dec 23, 2014 at 10:26:12AM +0800, Ganesh Mahendran wrote:
> Hello Minchan
> 
> 2014-12-20 10:25 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > Hey Ganesh,
> >
> > On Sat, Dec 20, 2014 at 09:43:34AM +0800, Ganesh Mahendran wrote:
> >> 2014-12-20 8:23 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> >> > On Fri, Dec 19, 2014 at 04:17:56PM -0800, Andrew Morton wrote:
> >> >> On Sat, 20 Dec 2014 09:10:43 +0900 Minchan Kim <minchan@kernel.org> wrote:
> >> >>
> >> >> > > It involves rehashing a lengthy argument with Greg.
> >> >> >
> >> >> > Okay. Then, Ganesh,
> >> >> > please add warn message about duplicaed name possibility althoug
> >> >> > it's unlikely as it is.
> >> >>
> >> >> Oh, getting EEXIST is easy with this patch.  Just create and destroy a
> >> >> pool 2^32 times and the counter wraps ;) It's hardly a serious issue
> >> >> for a debugging patch.
> >> >
> >> > I meant that I wanted to change from index to name passed from caller like this
> >> >
> >> > zram:
> >> >         zs_create_pool(GFP_NOIO | __GFP_HIGHMEM, zram->disk->first_minor);
> >> >
> >> > So, duplication should be rare. :)
> >>
> >> We still can not know whether the name is duplicated if we do not
> >> change the debugfs API.
> >> The API does not return the errno to us.
> >>
> >> How about just zsmalloc decides the name of the pool-id, like pool-x.
> >> When the pool-id reaches
> >> 0xffff.ffff, we print warn message about duplicated name, and stop
> >> creating the debugfs entry
> >> for the user.
> >
> > The idea is from the developer point of view to implement thing easy
> > but my point is we should take care of user(ie, admin) rather than
> > developer(ie, we).
> 
> Yes. I got it.
> 
> >
> > For user, /sys/kernel/debug/zsmalloc/zram0 would be more
> > straightforward and even it doesn't need zram to export
> > /sys/block/zram0/pool-id.
> 
> BTW, If we add a new argument in zs_create_pool(). It seems we also need to
> add argument in zs_zpool_create(). So, zpool/zswap/zbud will be
> modified to support
> the new API.
> Is that acceptable?

I think it's doable.
The zpool_create_pool has already zswap_zpool_type.
Ccing maintainers for double check.

Many thanks.


> 
> Thanks.
> 
> >
> > Thanks.
> >
> >>
> >> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
