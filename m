Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1C22E6B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 21:01:48 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so32532182pac.2
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 18:01:47 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id xg5si8012136pbc.77.2015.01.28.18.01.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 18:01:47 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so32481965pab.3
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 18:01:47 -0800 (PST)
Date: Thu, 29 Jan 2015 11:01:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150129020139.GB9672@blaptop>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
 <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <20150128145651.GB965@swordfish>
 <20150128233343.GC4706@blaptop>
 <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, sergey.senozhatsky.work@gmail.com

On Thu, Jan 29, 2015 at 10:57:38AM +0900, Sergey Senozhatsky wrote:
> On Thu, Jan 29, 2015 at 8:33 AM, Minchan Kim <minchan@kernel.org> wrote:
> 
> > On Wed, Jan 28, 2015 at 11:56:51PM +0900, Sergey Senozhatsky wrote:
> > > I don't like re-introduced ->init_done.
> > > another idea... how about using `zram->disksize == 0' instead of
> > > `->init_done' (previously `->meta != NULL')? should do the trick.
> >
> > It could be.
> >
> >
> care to change it?

Will try!

> 
> 
> 
> > >
> > >
> > > and I'm not sure I get this rmb...
> >
> > What makes you not sure?
> > I think it's clear and common pattern for smp_[wmb|rmb]. :)
> >
> 
> 
> well... what that "if (ret)" gives? it's almost always true, because the
> device is initialized during read/write operations (in 99.99% of cases).

If it was your concern, I'm happy to remove the check.(ie, actually,
I realized that after I push the button to send). Thanks!

> 
> -ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
